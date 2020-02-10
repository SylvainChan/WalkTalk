//
//  EntranceBuilder.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

// Scene Builder, init and config scene here

import UIKit

// MARK: - Main builder body
class EntranceBuilder {
    
    // - Storyboard
    private static let _storyboard = UIStoryboard(name: "EntranceStoryboard", bundle: nil)

    // - Creator
    static func createScene(request: BuildRequest) -> EntranceViewController {
        let viewController = _storyboard.instantiateViewController(ofType: EntranceViewController.self)
        let interactor = EntranceInteractor(request: request)
        let presenter = EntrancePresenter()
        let router = EntranceRouter()
        
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
extension EntranceBuilder {
    struct BuildRequest {

    }
}
