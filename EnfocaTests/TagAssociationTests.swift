//
//  TagAssociationTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest

@testable import Enfoca
class TagAssociationTests: XCTestCase {
    
//    var sut = TagAssociation()
    override func setUp() {
        super.setUp()
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let ass = TagAssociation(associationId: "001", wordPairId: "wpid", tagId: "tid")
        
        XCTAssertEqual(ass.wordPairId, "wpid")
        XCTAssertEqual(ass.tagId, "tid")
        XCTAssertEqual(ass.associationId, "001")
    }
    
    
}
