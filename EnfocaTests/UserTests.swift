//
//  UserTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class UserTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testInit_PropertiesShouldBeInitialized(){
        let user = User(enfocaId: 1, name: "bob", email: "test@email.com")
        
        XCTAssertEqual(user.enfocaId, 1)
        XCTAssertEqual(user.name, "bob")
        XCTAssertEqual(user.email, "test@email.com")
    }
    
    func testEquatable_ShouldBeEqualIfIdIsEqual(){
        let user = User(enfocaId: 1, name: "bob", email: "test@email.com")
        let user2 = User(enfocaId: 1, name: "not important", email: "nither is this")
        
        XCTAssertEqual(user, user2)
    }
    
    
}
