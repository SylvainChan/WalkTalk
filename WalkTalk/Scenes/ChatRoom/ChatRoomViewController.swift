//
//  ChatRoomViewController.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
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
protocol ChatRoomDisplayLogic: class {}

// MARK: - View Controller body
class ChatRoomViewController: ViewController, ChatRoomDisplayLogic {
    
    // VIP
    var interactor: ChatRoomBusinessLogic?
    var router: (NSObjectProtocol & ChatRoomRoutingLogic & ChatRoomDataPassing)?

}

// MARK: - View Lifecycle
extension ChatRoomViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK:- View Display logic entry point
extension ChatRoomViewController {
    
}
