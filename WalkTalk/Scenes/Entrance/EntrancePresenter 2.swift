//
//  EntrancePresenter.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//
// Purpose of Presenter:
// - Control view state, view presentation logic
// - Get response from interaction, parse it to view model, which will be the only view data received by View

import UIKit

// MARK: - Presentation logic goes here
protocol EntrancePresentationLogic {}

// MARK: - Presenter main body
class EntrancePresenter: EntrancePresentationLogic {
    
    // - VIP
    weak var viewController: EntranceDisplayLogic?
}

// MARK: - Presentation receiver
extension EntrancePresenter {
    
}
