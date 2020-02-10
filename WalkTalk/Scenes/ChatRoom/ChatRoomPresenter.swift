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
protocol ChatRoomPresentationLogic {
    
    func presentSearchPeer()
    func presentViewControllerDismissal(response: ChatRoom.Response.DismissViewController)
    func presentChatRoomStatus(response: ChatRoom.Response.ChatRoomStatus)
    func presentViewInit(response: ChatRoom.Response.PredefinedMessage)
    func presentQuitChat()
    func presentEmptyInputField()
    func presentUpdatedMessage(response: [ChatRoom.Response.IncomingMessage])
}

// MARK: - Presenter main body
class ChatRoomPresenter: ChatRoomPresentationLogic {
    // - VIP
    weak var viewController: ChatRoomDisplayLogic?
}

// MARK: - Presentation receiver
extension ChatRoomPresenter {
    // will show text corresponding to connection status
    func presentChatRoomStatus(response: ChatRoom.Response.ChatRoomStatus) {
        switch response.status {
        case .connected:
            self.viewController?.displayNavMessage(viewModel: ChatRoom.ViewModel.NavigationMessage(message: "You can chat now"))
            self.viewController?.displayUserInteractiveElements(viewModel: ChatRoom.ViewModel.UserInteractiveElements(enable: true))
        case .waiting:
            self.viewController?.displayNavMessage(viewModel: ChatRoom.ViewModel.NavigationMessage(message: "Waiting other to join..."))
            self.viewController?.displayUserInteractiveElements(viewModel: ChatRoom.ViewModel.UserInteractiveElements(enable: false))
        }
    }
    
    func presentViewInit(response: ChatRoom.Response.PredefinedMessage) {
        let strings = response.all.compactMap{ $0.message }
        self.viewController?.displayPredefinedMessage(viewModel: ChatRoom.ViewModel.PredefinedMessage(all: strings))
    }
    
    func presentEmptyInputField() {
        self.viewController?.displayEmptyInputField()
    }
    
    func presentQuitChat() {
        self.viewController?.quitChat()
    }
    
    func presentUpdatedMessage(response: [ChatRoom.Response.IncomingMessage]) {
        let messages = response.compactMap { $0.message }
        self.viewController?.displayLatestMessage(messages: messages)
    }
    
    func presentViewControllerDismissal(response: ChatRoom.Response.DismissViewController) {
        self.viewController?.dismissViewController(viewModel: ChatRoom.ViewModel.DismissViewController(viewcontroller: response.viewcontroller))
    }
    
    func presentSearchPeer() {
        self.viewController?.displaySearchPeer()
    }
}
