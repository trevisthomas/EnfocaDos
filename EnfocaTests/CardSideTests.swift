//
//  CardSideTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class CardSideTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldContainCorrectStrings(){
        XCTAssertEqual(CardSide.term.rawValue, "Term")
        XCTAssertEqual(CardSide.definition.rawValue, "Definition")
        XCTAssertEqual(CardSide.random.rawValue, "Random")
        
    }
    
}
