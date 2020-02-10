//
//  ChatRoomRouter.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

// View navigation events go here

import UIKit
import MultipeerConnectivity

// MARK: - The main interface to be called by others
@objc protocol ChatRoomRoutingLogic {
    
    func routeToMCBrowser()
    func routeBack()
    
}

// MARK: - The possible elements that can be
protocol ChatRoomDataPassing {
  var dataStore: ChatRoomDataStore? { get }
}

// MARK: - Main router body
class ChatRoomRouter: NSObject, ChatRoomRoutingLogic, ChatRoomDataPassing {
    // - VIP
    weak var viewController: (ChatRoomViewController & MCBrowserViewControllerDelegate)?
    var dataStore: ChatRoomDataStore?
}

// MARK: - Routing and datapassing for one nav action
extension ChatRoomRouter {
    
    func routeBack() {
        self.viewController?.navigationController?.popViewController(animated: true)
    }
    
    func routeToMCBrowser() {
        guard let dataStore = self.dataStore else { return }
        let vc = MCBrowserViewController(
            serviceType: dataStore.connection.credential.channel,
            session: dataStore.connection.session
        )
        vc.delegate = self.viewController
        self.viewController?.present(vc, animated: true, completion: nil)
    }
}
