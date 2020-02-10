//
//  UserConnection.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 9/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit
import MultipeerConnectivity

// Retain and handle connect level information
struct UserConnection {
    static var pushToken: String? = nil
    
    class Credential: NSObject, Codable {
        let channel: String
        let name: String
        
        init(channel: String, name: String) {
            self.channel = channel
            self.name = name
        }
    }
    
    let session: MCSession
    let credential: Credential

    init(session: MCSession, channel: String, name: String) {
        self.session = session
        self.credential = Credential(channel: channel, name: name)
    }
}
