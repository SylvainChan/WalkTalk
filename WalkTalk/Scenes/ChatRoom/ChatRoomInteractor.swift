//
//  ChatRoomInteractor.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Requests from view
protocol ChatRoomBusinessLogic {
    func requestHandleViewInit()
    func requestHandleBarBackButtonDidPress()
    func requestHandleBarSearchButtonDidPress()
    func requestHandleSendAction(request: ChatRoom.Request.SendAction)
    func requestHandlePredefinedMessageDidSelect(request: ChatRoom.Request.PredefinedMessageSelect)
    func requestHandleTokenUpdateNotification()
    func requestHandleMCSearcherFinish(request: ChatRoom.Request.MCSearcher)
}

// MARK: - Datas retain in interactor defines here
protocol ChatRoomDataStore {
    var connection: UserConnection { get }
    var me: Sender { get set }
    
}

// MARK: - Interactor Body
class ChatRoomInteractor: NSObject, ChatRoomBusinessLogic, ChatRoomDataStore {
    
    // VIP Properties
    var presenter: ChatRoomPresentationLogic?
    var worker: ChatRoomWorker?
    
    // Chat room connection related
    let connection: UserConnection
    private var assistant: MCAdvertiserAssistant?

    // User / Peer related
    var me: Sender
    private var senderMap: [MCPeerID: Sender] = [:]
    
    // For send message among network
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // state of current chatroom messages
    private var messages: [ChatRoom.Response.IncomingMessage] = []
    
    // Init
    init(request: ChatRoomBuilder.BuildRequest) {
        self.connection = request.connection
        self.me = Sender(name: request.connection.credential.name, color: UIColor.random)
    }
    
    // deinit
    deinit {
        self.assistant?.stop()
        self.connection.session.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - view appear action
extension ChatRoomInteractor {
    
    func requestHandleViewInit() {
        // Start make myself visible to other in Bonjour network
        let assistant = MCAdvertiserAssistant(serviceType: self.connection.credential.channel, discoveryInfo: nil, session: self.connection.session)
        assistant.delegate = self
        assistant.start()
        self.assistant = assistant
        
        // Predefine messages
        let allPredefinedMessages = ChatRoom.Constant.ShortCutMessage.allCases
        self.presenter?.presentViewInit(response: ChatRoom.Response.PredefinedMessage(all: allPredefinedMessages))
        self.updateChatRoomStatus()
        
        // App termination listener
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAppWillTerminateNotification), name: NSNotification.Name.init(WTNotification.appWillTerminate.rawValue), object: nil)
    }
}

// MARK: - Notification
extension ChatRoomInteractor {
    /*
     If app will terminate, will disconnect current chatroom
     Romote notification will not be received as we treat it as exiting chat room
     */
    @objc func didReceiveAppWillTerminateNotification() {
        DispatchQueue.main.async {
            self.assistant?.stop()
            self.connection.session.disconnect()
            NotificationCenter.default.removeObserver(self)
        }
    }
}

// MARK: - view user interaction
extension ChatRoomInteractor {
    
    // Prepare data for handling predefined message buttons in chatroom ui, then pass to presenter
    func requestHandlePredefinedMessageDidSelect(request: ChatRoom.Request.PredefinedMessageSelect) {
        // get predefined message in enum
        let preMessages = ChatRoom.Constant.ShortCutMessage.allCases
        
        // ensure there is at least one message
        guard request.index < preMessages.count else { return }
        
        let message = preMessages[request.index]
        if let textData = message.message.data(using: .utf8) {
            self.boardcastMessage(message: message.message)
            self.sendMessage(Message(type: Message.PayloadType.message, displayName: self.connection.credential.name, message: textData))
            self.messages.append(ChatRoom.Response.IncomingMessage(message: .myText(peerId: self.connection.session.myPeerID, sender: self.me, message: message.message)))
            self.presenter?.presentUpdatedMessage(response: self.messages)
        }
    }
    
    // Search for peer in same channel
    func requestHandleBarSearchButtonDidPress() {
        self.presenter?.presentSearchPeer()
    }
    
    // Treat as disconnect, leave the chatroom
    func requestHandleBarBackButtonDidPress() {
        self.assistant?.stop()
        self.connection.session.disconnect()
        self.presenter?.presentQuitChat()
    }
    
    // Send message handling, will send to connected peers and show to self's view also
    func requestHandleSendAction(request: ChatRoom.Request.SendAction) {
        if
            let text = request.textFieldText,
            let textData = text.data(using: .utf8)
        {
            let message = Message(type: .message, displayName: self.connection.credential.name, message: textData)
            self.sendMessage(message)
            self.boardcastMessage(message: text)
            self.messages.append(ChatRoom.Response.IncomingMessage(message: .myText(peerId: self.connection.session.myPeerID, sender: self.me, message: text)))
            self.presenter?.presentUpdatedMessage(response: self.messages)
            self.presenter?.presentEmptyInputField()
        }
        else {
            // no text handling
        }
    }
}

// MARK: - message hub
extension ChatRoomInteractor {
    // Send greeting to someone, or all participants
    private func sendGreeting(to peer: MCPeerID? = nil) {
        let toPeer: [MCPeerID]
        
        if let peer = peer {
            toPeer = [peer]
        }
        else {
            toPeer = self.connection.session.connectedPeers
        }
        
        let greeting = Message(type: Message.PayloadType.greeting, displayName: self.connection.credential.name, message: nil)
        self.boardcastDeviceTokenIfNeeded()
        self.sendMessage(greeting, toPeers: toPeer)
    }
    
    /* Send request to all connected peers in order to:
    -   update their display name, as well as Device token for remote notification
    -   update their Device token for remote notification
     */
    private func sendRequestForIndentity() {
        let request = Message(type: .requestIdentity, displayName: self.connection.credential.name, message: nil)
        self.sendMessage(request)
    }
    
    /*
     Common message sender
     */
    private func sendMessage(_ message: Message, toPeers peers: [MCPeerID]? = nil) {
        guard let data = try? self.encoder.encode(message) else { return }
        try? self.connection.session.send(data, toPeers: peers ?? self.connection.session.connectedPeers, with: .reliable)
    }
}

// MARK: - session delegate
extension ChatRoomInteractor: MCSessionDelegate {
    
    /*
     Display connection update event to chat view
     If peer disconnected, will remove it from sender list
     */
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .notConnected:
            if let peer = self.senderMap[peerID] {
                self.messages.append(ChatRoom.Response.IncomingMessage(message: .leaver(name: peer.name + " has left the chat!")))
                self.presenter?.presentUpdatedMessage(response: self.messages)
                self.senderMap.removeValue(forKey: peerID)
            }
            
        case .connected:
            if let peer = self.senderMap[peerID] {
                self.messages.append(ChatRoom.Response.IncomingMessage(message: .newJoiner(name: peer.name + " has joined the chat!")))
                self.presenter?.presentUpdatedMessage(response: self.messages)
            }
            
        default:
            break
        }
        
        self.updateChatRoomStatus()
    }
    
    /*
     Receive data handler.
     Currently only handle 4 types:
     - greeting
        - Will cache its display name and show it as that peer's name in chat room
     - requestIdentity
        - Will broadcast my id and push token if there is any to the network
     - message
        - Will show new message to chatroom
     - deviceToken
        - Will cache this peer's push device token, and send notification message afterward for messages sent by us
     */
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = try? self.decoder.decode(Message.self, from: data) else { return }
        
        switch message.type {
        case .greeting:
            self.setSenderName(name: message.displayName, for: peerID)
            self.messages.append(ChatRoom.Response.IncomingMessage(message: .newJoiner(name: message.displayName + " is in the chatroom now!")))
            self.presenter?.presentUpdatedMessage(response: self.messages)
            
        case .requestIdentity:
            self.sendGreeting(to: peerID)
            
        case .message:
            self.setSenderName(name: message.displayName, for: peerID)
            // try parse it into string
            if
                let messageData = message.message,
                let string = String(data: messageData, encoding: .utf8)
            {
                let sender = self.getSenderByPeer(peer: peerID)
                let displayName = sender.name
                self.messages.append(ChatRoom.Response.IncomingMessage(message: .text(peerId: peerID, sender: Sender(name: displayName, color: sender.color), message:string)))
                self.presenter?.presentUpdatedMessage(response: self.messages)
            }
            
        case .deviceToken:
            if
                let messageData = message.message,
                let token = String(data: messageData, encoding: .utf8)
            {
                let sender = self.getSenderByPeer(peer: peerID)
                sender.deviceToken = token
            }
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // For image / video transmission
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // For image / video transmission
    }
    
}

// MARK: - Private Helper
extension ChatRoomInteractor {
    // if no one connect, disable chat room
    private func updateChatRoomStatus() {
        let status: ChatRoom.Response.ChatRoomStatus.Status = self.connection.session.connectedPeers.count > 0 ? .connected : .waiting
        self.presenter?.presentChatRoomStatus(response: ChatRoom.Response.ChatRoomStatus(status: status))
    }
    
    // update peer's name in chatroom
    private func setSenderName(name: String, for peer: MCPeerID) {
        let sender = self.getSenderByPeer(peer: peer)
        sender.updateName(name: name)
    }
    
    // lazy load peer sender obj
    private func getSenderByPeer(peer: MCPeerID) -> Sender {
        if let sender = self.senderMap[peer] {
            return sender
        }
        else {
            let color = UIColor.random
            let sender = Sender(name: peer.displayName, color: color)
            self.senderMap[peer] = sender
            
            return sender
        }
    }
}

// MARK: - notification
extension ChatRoomInteractor: URLSessionDelegate {
    // if get pust token update, will immediate tell other peers
    func requestHandleTokenUpdateNotification() {
        self.boardcastDeviceTokenIfNeeded()
    }
    
    // tell connected peers about the newest token
    private func boardcastDeviceTokenIfNeeded() {
        if let token = UserConnection.pushToken, let data = token.data(using: .utf8) {
            self.me.deviceToken = token
            let message = Message(type: .deviceToken, displayName: self.me.name, message: data)
            self.sendMessage(message)
        }
    }
    
    // Send push notification of the sending message from me, to all connected peers will notification registered
    private func boardcastMessage(message: String) {
        let deviceToken = self.senderMap.compactMap { $0.value.deviceToken }
        
        // HTTP POST REQUEST CONSTRUCTION
        deviceToken.forEach {
            var request = URLRequest(url: URL(string: "http://sylvain.hk/push/push.php")!)
            request.httpMethod = "POST"
            
            let postString = "message=\(message)&sender=\(self.me.name)&token=\($0)"
            request.httpBody = postString.data(using: .utf8)
            
            let session = URLSession.init(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
            session.dataTask(with: request) { (data, response, error) in
                // best effort
                
            }.resume()
            
        }
    }
    
    // Always by pass ssl check, to save time for this demo
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard
            let trust = challenge.protectionSpace.serverTrust
            else {
                completionHandler(.performDefaultHandling, nil)
                return
        }
        
        let credential = URLCredential(trust: trust)
        completionHandler(.useCredential, credential)
    }
}

// MARK: - Assistant Delegate
extension ChatRoomInteractor: MCAdvertiserAssistantDelegate {
    /*
     After mc peer search complete
     - dismiss search view
     - exchange my sender info with other peers
    */
    func requestHandleMCSearcherFinish(request: ChatRoom.Request.MCSearcher) {
        self.presenter?.presentViewControllerDismissal(response: ChatRoom.Response.DismissViewController(viewcontroller: request.viewcontroller))
        
        // greeting
        self.sendGreeting()
        self.sendRequestForIndentity()
        self.boardcastDeviceTokenIfNeeded()
    }
}
