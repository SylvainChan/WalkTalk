//
//  EntranceRouter.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

// View navigation events go here

import UIKit

// MARK: - The main interface to be called by others
@objc protocol EntranceRoutingLogic {}

// MARK: - The possible elements that can be
protocol EntranceDataPassing {
  var dataStore: EntranceDataStore? { get }
}

// MARK: - Main router body
class EntranceRouter: NSObject, EntranceRoutingLogic, EntranceDataPassing {
    // - VIP
    weak var viewController: EntranceViewController?
    var dataStore: EntranceDataStore?
}

// MARK: - Routing and datapassing for one nav action
extension EntranceRouter {
    
}
