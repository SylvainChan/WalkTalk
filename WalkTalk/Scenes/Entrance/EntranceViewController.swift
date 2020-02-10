//
//  EntranceViewController.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

/*
 There should have no extra businees logic in view controller
 - control view state
 - receive view models and place it at right views
 
 - for interaction, create request and send to interactor
 */

import UIKit
import MultipeerConnectivity

// MARK: - Display logic, receive view model from presenter and present
protocol EntranceDisplayLogic: class {}

// MARK: - View Controller body
class EntranceViewController: ViewController, EntranceDisplayLogic {
    
    // UI elements
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var createButton: UIButton!
    
    @IBOutlet weak var channelInputStackView: UIStackView!
    @IBOutlet weak var nameInputStackView: UIStackView!
    
    @IBOutlet weak var channelInputField: UITextField!
    @IBOutlet weak var usernameInputField: UITextField!
    
    //
    private var peer: MCPeerID?
    private var session: MCSession?
    
    // keys
    private let peerKey = "pPeer"
    private let nameKey = "pName"
    private let channelKey = "pChannel"
    
    // VIP
    var interactor: EntranceBusinessLogic?
    var router: (NSObjectProtocol & EntranceRoutingLogic & EntranceDataPassing)?

}

// MARK: - View Lifecycle
extension EntranceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // prefill
        if let previousName = UserDefaults.standard.string(forKey: self.nameKey) {
            self.usernameInputField.text = previousName
        }
        
        if let previousChannel = UserDefaults.standard.string(forKey: self.channelKey) {
            self.channelInputField.text = previousChannel
        }
        
        // view init
        self.title = "Walkie"
        self.enableButtonIfNeeded()
    }
}

// MARK:- View Display logic entry point
extension EntranceViewController {
    
    private func generatePeer() {
        let id = UIDevice.current.name
        let peer: MCPeerID
        
        if
            let previousPeerData = UserDefaults.standard.data(forKey: self.peerKey),
            let previousPeer = try? NSKeyedUnarchiver.unarchivedObject(ofClass: MCPeerID.self, from: previousPeerData),
            previousPeer.displayName == id
        {
            peer = previousPeer
        }
        else {
            peer = MCPeerID(displayName: id)
            
            // set to cache
            let peerData = try? NSKeyedArchiver.archivedData(withRootObject: peer, requiringSecureCoding: true)
            UserDefaults.standard.set(peerData, forKey: self.peerKey)
            UserDefaults.standard.synchronize()
        }
        
        self.peer = peer
    }
    
    private func generateSession() {
        guard let peer = self.peer else { return }
        
        // safely quit previous connection if there is any
        self.session?.disconnect()
        
        let session = MCSession(peer: peer, securityIdentity: nil, encryptionPreference: .required)
        self.session = session
    }
    
    @IBAction func buttonDidPress(_ sender: UIButton) {
        
        if self.channelInputStackView.arrangedSubviews.count > 1 {
            self.channelInputStackView.arrangedSubviews[1].removeFromSuperview()
        }
        
        self.generatePeer()
        self.generateSession()
        
        guard
            let channel = self.channelInputField.text,
            let name = self.usernameInputField.text,
            let session = self.session,
            let regex = try? NSRegularExpression(pattern: "^([a-zA-Z0-9]*[a-zA-Z][a-zA-Z0-9]*){1,15}$", options: .caseInsensitive)
        else { return }
        
        let channelStringRange = NSRange(location: 0, length: channel.count)
        guard regex.firstMatch(in: channel, options: [], range: channelStringRange) != nil else {
            let errorLabel = UILabel()
            errorLabel.translatesAutoresizingMaskIntoConstraints = false
            errorLabel.numberOfLines = 0
            errorLabel.text = "Channel name must contain at least one alphabetic character + Only alphanumeric is accepted."
            errorLabel.font = UIFont.systemFont(ofSize: 10, weight: .bold)
            errorLabel.textColor = UIColor.red
            self.channelInputStackView.addArrangedSubview(errorLabel)
            return
        }
        
        // set to cache
        UserDefaults.standard.set(name, forKey: self.nameKey)
        UserDefaults.standard.set(channel, forKey: self.channelKey)
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.async {
            switch sender {
            case self.searchButton:
                let vc = MCBrowserViewController(
                    serviceType: channel,
                    session: session
                )
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            case self.createButton:
                self.pushToChatRoom()
                
            default: return
            }
        }
    
    }
}

// MARK: - Input checking logic goes here
extension EntranceViewController {
    @IBAction func textFieldDidUpdate(_ sender: Any) {
        self.enableButtonIfNeeded()
    }
    
    private func enableButtonIfNeeded() {
        let enable = !(self.channelInputField.text?.isEmpty ?? true) && !(self.usernameInputField.text?.isEmpty ?? true)
        
        self.createButton.isUserInteractionEnabled = enable
        self.searchButton.isUserInteractionEnabled = enable
        
        if enable {
            self.createButton.alpha = 1
            self.searchButton.alpha = 1
        }
        else {
            self.createButton.alpha = 0.3
            self.searchButton.alpha = 0.3
        }
    }

}

// MARK: - browser view delegate
extension EntranceViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            self.pushToChatRoomIfHaveConnection()
        }
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true) {
            self.pushToChatRoomIfHaveConnection()
        }
    }
}

extension EntranceViewController {
    
    func pushToChatRoomIfHaveConnection() {
        if self.session?.connectedPeers.count ?? 0 > 0 {
            self.pushToChatRoom()
        }
    }
    
    func pushToChatRoom() {
        guard
            let channel = self.channelInputField.text,
            let name = self.usernameInputField.text,
            let session = self.session
        else { return }
        
        let vc = ChatRoomBuilder.createScene(request: ChatRoomBuilder.BuildRequest(connection: UserConnection(session: session, channel: channel, name: name)))
        self.navigationController?.pushViewController(vc, animated: true)
    }
        
}
