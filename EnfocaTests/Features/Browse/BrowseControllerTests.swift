//
//  BrowseControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class BrowseControllerTests: XCTestCase {
    var sut : BrowseController!
    var delegate : MockBrowseControllerDelegate!
    var services : MockWebService!
    
    override func setUp() {
        super.setUp()
        delegate = MockBrowseControllerDelegate()
        services = MockWebService()
        getAppDelegate().webService = services
    }
    
    func testTitle_ShouldBeTagName(){
        let tag = Tag(tagId: "00", name: "Test")
        
        sut = BrowseController(tag: tag, delegate: delegate)
        
        XCTAssertEqual(sut.title(), tag.name)
    }
    
}

class MockBrowseControllerDelegate: BrowseControllerDelegate {
    
}
