//
//  ChatRoomInteractor.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

import UIKit

// MARK: - Requests from view
protocol ChatRoomBusinessLogic {}

// MARK: - Datas retain in interactor defines here
protocol ChatRoomDataStore {}

// MARK: - Interactor Body
class ChatRoomInteractor: ChatRoomBusinessLogic, ChatRoomDataStore {
    
    // VIP Properties
    var presenter: ChatRoomPresentationLogic?
    var worker: ChatRoomWorker?

    // Init
    init(request: ChatRoomBuilder.BuildRequest) {

    }
}

// MARK: - Business
extension ChatRoomInteractor {
    
}
