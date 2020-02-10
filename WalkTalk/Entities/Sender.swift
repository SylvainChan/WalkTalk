//
//  User.swift
//  WalkTalk
//
//  Created by Sylvain Chan on 7/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import UIKit

// Peer extra information, for F/E display purpose
class Sender {
    private(set) var name: String
    let color: UIColor
    var deviceToken: String? = nil
    
    func updateName(name: String) {
        self.name = name
    }
    
    init(name: String, color: UIColor) {
        self.name = name
        self.color = color
    }
}
