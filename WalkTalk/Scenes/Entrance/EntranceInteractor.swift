//
//  EntranceInteractor.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

import UIKit

// MARK: - Requests from view
protocol EntranceBusinessLogic {}

// MARK: - Datas retain in interactor defines here
protocol EntranceDataStore {}

// MARK: - Interactor Body
class EntranceInteractor: EntranceBusinessLogic, EntranceDataStore {
    
    // VIP Properties
    var presenter: EntrancePresentationLogic?
    var worker: EntranceWorker?

    // Init
    init(request: EntranceBuilder.BuildRequest) {

    }
}

// MARK: - Business
extension EntranceInteractor {
    
}
