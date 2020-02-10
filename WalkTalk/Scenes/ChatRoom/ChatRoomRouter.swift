//
//  ChatRoomRouter.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

// View navigation events go here

import UIKit

// MARK: - The main interface to be called by others
@objc protocol ChatRoomRoutingLogic {}

// MARK: - The possible elements that can be
protocol ChatRoomDataPassing {
  var dataStore: ChatRoomDataStore? { get }
}

// MARK: - Main router body
class ChatRoomRouter: NSObject, ChatRoomRoutingLogic, ChatRoomDataPassing {
    // - VIP
    weak var viewController: ChatRoomViewController?
    var dataStore: ChatRoomDataStore?
}

// MARK: - Routing and datapassing for one nav action
extension ChatRoomRouter {
    
}
