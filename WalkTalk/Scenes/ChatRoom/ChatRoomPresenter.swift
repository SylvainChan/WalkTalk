//
//  ChatRoomPresenter.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//
// Purpose of Presenter:
// - Control view state, view presentation logic
// - Get response from interaction, parse it to view model, which will be the only view data received by View

import UIKit

// MARK: - Presentation logic goes here
protocol ChatRoomPresentationLogic {}

// MARK: - Presenter main body
class ChatRoomPresenter: ChatRoomPresentationLogic {
    
    // - VIP
    weak var viewController: ChatRoomDisplayLogic?
}

// MARK: - Presentation receiver
extension ChatRoomPresenter {
    
}
