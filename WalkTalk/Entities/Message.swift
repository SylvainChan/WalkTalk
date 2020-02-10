//
//  Message.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit

// Message entity that will be sent over network
struct Message: Codable {
    enum PayloadType: Int, Codable {
        case greeting
        case requestIdentity
        case message
//        case retrieveHistory
        case deviceToken
    }
    
    let type: PayloadType
    let displayName: String
    let message: Data?
}
