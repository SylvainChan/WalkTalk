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
    func viewDidAppear()
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
    
    //
    let connection: UserConnection
    private var assistant: MCAdvertiserAssistant?

    //
    var me: Sender
    private var senderMap: [MCPeerID: Sender] = [:]
    
    //
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    //
    private var messages: [ChatRoom.Response.IncomingMessage] = []
    
    // Init
    init(request: ChatRoomBuilder.BuildRequest) {
        self.connection = request.connection
        self.me = Sender(name: request.connection.credential.name, color: UIColor.random)
    }
    
    deinit {
        self.assistant?.stop()
        self.connection.session.disconnect()
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - view appear action
extension ChatRoomInteractor {
    
    func requestHandleViewInit() {
        
        // invite handle
        let assistant = MCAdvertiserAssistant(serviceType: self.connection.credential.channel, discoveryInfo: nil, session: self.connection.session)
        assistant.delegate = self
        assistant.start()
        self.assistant = assistant
        
        // predefine message
        let allPredefinedMessages = ChatRoom.Constant.ShortCutMessage.allCases
        self.presenter?.presentViewInit(response: ChatRoom.Response.PredefinedMessage(all: allPredefinedMessages))
        self.updateChatRoomStatus()
        
        // app term
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveAppWillTerminateNotification), name: NSNotification.Name.init(WTNotification.appWillTerminate.rawValue), object: nil)
    }
    
    func viewDidAppear() {
    }
    
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
    func requestHandlePredefinedMessageDidSelect(request: ChatRoom.Request.PredefinedMessageSelect) {
        let preMessages = ChatRoom.Constant.ShortCutMessage.allCases
        
        guard request.index < preMessages.count else { return }
        
        let message = preMessages[request.index]
        
        if let textData = message.message.data(using: .utf8) {
            self.boardcastMessage(message: message.message)
            self.sendMessage(Message(type: Message.PayloadType.message, displayName: self.connection.credential.name, message: textData))
            self.messages.append(ChatRoom.Response.IncomingMessage(message: .myText(peerId: self.connection.session.myPeerID, sender: self.me, message: message.message)))
            self.presenter?.presentUpdatedMessage(response: self.messages)
        }
    }
    
    func requestHandleBarSearchButtonDidPress() {
        self.presenter?.presentSearchPeer()
    }
    
    func requestHandleBarBackButtonDidPress() {
        self.assistant?.stop()
        self.connection.session.disconnect()
        self.presenter?.presentQuitChat()
    }
    
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
    // send greeting to someone, or all participants
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
    
    private func sendRequestForIndentity() {
        let request = Message(type: .requestIdentity, displayName: self.connection.credential.name, message: nil)
        self.sendMessage(request)
    }
    
    private func sendMessage(_ message: Message, toPeers peers: [MCPeerID]? = nil) {
        guard let data = try? self.encoder.encode(message) else { return }
        
        try? self.connection.session.send(data, toPeers: peers ?? self.connection.session.connectedPeers, with: .reliable)
    }
}

// MARK: - session delegate
extension ChatRoomInteractor: MCSessionDelegate {
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
            
        case .retrieveHistory:
            break
            
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
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
}

// MARK: - Private Helper
extension ChatRoomInteractor {
    private func updateChatRoomStatus() {
        let status: ChatRoom.Response.ChatRoomStatus.Status = self.connection.session.connectedPeers.count > 0 ? .connected : .waiting
        self.presenter?.presentChatRoomStatus(response: ChatRoom.Response.ChatRoomStatus(status: status))
    }
    
    private func setSenderName(name: String, for peer: MCPeerID) {
        let sender = self.getSenderByPeer(peer: peer)
        sender.updateName(name: name)
    }
    
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
    func requestHandleTokenUpdateNotification() {
        self.boardcastDeviceTokenIfNeeded()
    }
    
    private func boardcastDeviceTokenIfNeeded() {
        if let token = UserConnection.pushToken, let data = token.data(using: .utf8) {
            self.me.deviceToken = token
            let message = Message(type: .deviceToken, displayName: self.me.name, message: data)
            self.sendMessage(message)
        }
    }
    
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
    
    func requestHandleMCSearcherFinish(request: ChatRoom.Request.MCSearcher) {
        self.presenter?.presentViewControllerDismissal(response: ChatRoom.Response.DismissViewController(viewcontroller: request.viewcontroller))
        
        // greeting
        self.sendGreeting()
        self.sendRequestForIndentity()
        self.boardcastDeviceTokenIfNeeded()
    }
}
