//
//  Message.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit

struct Message: Codable {
    enum PayloadType: Int, Codable {
        case greeting
        case requestIdentity
        case message
    }
    
    let type: PayloadType
    let displayName: String
    let message: Data?
}
