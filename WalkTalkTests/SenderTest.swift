//
//  SenderTest.swift
//  WalkTalkTests
//
//  Created by Sylvain Chan on 10/2/2020.
//  Copyright © 2020 Sylvain. All rights reserved.
//

import XCTest
@testable import WalkTalk

class SenderTest: XCTestCase {

    let oldName = "name"
    let color = UIColor.red
    var sender: Sender?
    
    override func setUp() {
        let sender = Sender(name: oldName, color: color)
        self.sender = sender
    }

    override func tearDown() {
        
    }

    func testSenderInit() {
        guard let sender = self.sender else { return }
        XCTAssert(sender.name == self.oldName && sender.color == self.color, "init sender result mismatch")
    }

    func testSenderFunction() {
        let newName = "newName"
        self.sender?.updateName(name: newName)
        
        XCTAssert(newName == self.sender?.name, "cannot update name")
    }

}
