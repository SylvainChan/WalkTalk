//
//  ChatRoomModels.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright (c) 2020 Sylvain. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// MARK: - Models will go here
// Defines request, response and corresponding view models
enum ChatRoom {
    
    enum Constant {
        enum ShortCutMessage: CaseIterable {
            case hello
            case bye
            case niceToMeetYou
            case howAreYou
            case niceToMeetYouToo
            
            var message: String {
                switch self {
                case .bye:              return "Bye~"
                case .hello:            return "Hello!"
                case .howAreYou:        return "How are you?"
                case .niceToMeetYou:    return "Nice to meet you!"
                case .niceToMeetYouToo:    return "Nice to meet you too!"
                }
            }
        }
    }
    
    struct Request {
        
        struct MCSearcher {
            let viewcontroller: MCBrowserViewController
        }
        
        struct SendAction {
            let textFieldText: String?
        }
        
        struct PredefinedMessageSelect {
            let index: Int
        }
    }
    
    struct Response {
        struct DismissViewController {
            let viewcontroller: UIViewController
        }
        
        struct IncomingMessage {
            enum ClassifiedMessage {
                case text(peerId: MCPeerID, sender: Sender, message: String)
                case myText(peerId: MCPeerID, sender: Sender, message: String)
                case newJoiner(name: String)
                case leaver(name: String)
            }
            
            let message: ClassifiedMessage
        }
        
        struct PredefinedMessage {
            let all: [ChatRoom.Constant.ShortCutMessage]
        }
        
        struct ChatRoomStatus {
            enum Status {
                case waiting
                case connected
            }
            
            let status: Status
        }
    }
    
    struct ViewModel {
        struct DismissViewController {
            let viewcontroller: UIViewController
        }
        
        struct PredefinedMessage {
            let all: [String]
        }
        
        struct NavigationMessage {
            let message: String
        }
        
        struct UserInteractiveElements {
            let enable: Bool
        }
    }
}
