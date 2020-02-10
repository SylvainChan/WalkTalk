//
//  ChatRoomBuilder.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

// Scene Builder, init and config scene here

import UIKit

// MARK: - Main builder body
class ChatRoomBuilder {
    
    // - Storyboard
    private static let _storyboard = UIStoryboard(name: "ChatRoomStoryboard", bundle: nil)

    // - Creator
    static func createScene(request: BuildRequest) -> ChatRoomViewController {
        let viewController = _storyboard.instantiateViewController(ofType: ChatRoomViewController.self)
        let interactor = ChatRoomInteractor(request: request)
        let presenter = ChatRoomPresenter()
        let router = ChatRoomRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor

        return viewController
    }
}

/* 
    MARK: - Scene building raw materials
    - All params inject here
*/
extension ChatRoomBuilder {
    struct BuildRequest {

    }
}