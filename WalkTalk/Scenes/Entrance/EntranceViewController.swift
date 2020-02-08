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
    
    //
    private let session = MCSession(
        peer: MCPeerID(displayName: UIDevice.current.name),
        securityIdentity: nil,
        encryptionPreference: MCEncryptionPreference.required
    )
    private var assistant: MCAdvertiserAssistant?
    
    // VIP
    var interactor: EntranceBusinessLogic?
    var router: (NSObjectProtocol & EntranceRoutingLogic & EntranceDataPassing)?

}

// MARK: - View Lifecycle
extension EntranceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.session.delegate = self
    }
}

// MARK:- View Display logic entry point
extension EntranceViewController {
    
    @IBAction func buttonDidPress(_ sender: UIButton) {
        DispatchQueue.main.async {
            
            switch sender {
            case self.searchButton:
                let vc = MCBrowserViewController(
                    serviceType: "ioscreator-chat",
                    session: self.session
                )
                vc.delegate = self
                self.present(vc, animated: true, completion: nil)
                
            case self.createButton:
                let assistant = MCAdvertiserAssistant(
                    serviceType: "ioscreator-chat",
                    discoveryInfo: nil,
                    session: self.session
                    
                )
                assistant.delegate = self
                assistant.start()
                self.assistant = assistant
                
            default: return
            }
        }
    
    }
}

extension EntranceViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
}

extension EntranceViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true, completion: nil)
    }
    
}

extension EntranceViewController: MCAdvertiserAssistantDelegate {
    func advertiserAssistantWillPresentInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        
    }
    
    func advertiserAssistantDidDismissInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {
        
    }
    
    
}
