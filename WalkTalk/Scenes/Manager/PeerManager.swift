//
//  UserManager.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class PeerManager: NSObject {
    static let shared = PeerManager()
    
    private(set) var user: User = User(id: "", name: "")
}

// MARK: - setter
extension PeerManager {
    func setCurrent(user: User) {
        self.user = user
    }
}

// MARK: - getter
extension PeerManager {
    
    
    
}
