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

// MARK: - Display logic, receive view model from presenter and present
protocol EntranceDisplayLogic: class {}

// MARK: - View Controller body
class EntranceViewController: ViewController, EntranceDisplayLogic {
    
    // VIP
    var interactor: EntranceBusinessLogic?
    var router: (NSObjectProtocol & EntranceRoutingLogic & EntranceDataPassing)?

}

// MARK: - View Lifecycle
extension EntranceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK:- View Display logic entry point
extension EntranceViewController {
    
}
