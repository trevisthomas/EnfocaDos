//
//  CardOrderTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca

class CardOrderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_StringShouldCreateEnum() {
        
        XCTAssertEqual(CardOrder.hardest.rawValue, "Hardest")
        XCTAssertEqual(CardOrder.slowest.rawValue, "Slowest to answer")
        XCTAssertEqual(CardOrder.easiest.rawValue, "Easiest")
        XCTAssertEqual(CardOrder.leastStudied.rawValue, "Least Studied")
        XCTAssertEqual(CardOrder.latestAdded.rawValue, "Most Reciently Added")
        XCTAssertEqual(CardOrder.random.rawValue, "Random")
        XCTAssertEqual(CardOrder.leastRecientlyStudied.rawValue, "Least Reciently Studied")
    }
    
}
