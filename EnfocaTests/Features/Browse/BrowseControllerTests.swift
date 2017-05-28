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
        
        sut = BrowseController(tag: tag, wordOrder: .definitionAsc, delegate: delegate)
        
        XCTAssertEqual(sut.title(), tag.name)
        XCTAssertEqual(sut.wordOrder, .definitionAsc)
    }
    
    func testBrowse_ShoudGetResults(){
        let tag = Tag(tagId: "00", name: "Test")
        let order : WordPairOrder = .definitionAsc
        
        sut = BrowseController(tag: tag, wordOrder: order, delegate: delegate)
        
        sut.loadWordPairs()
        
        XCTAssertEqual(delegate.browseResult, services.wordPairs)
        
    }
    
}

class MockBrowseControllerDelegate: BrowseControllerDelegate {
    var errorTitle: String!
    var errorMessage: String!
    var browseResult: [WordPair] = []
    
    func onBrowseResult(words: [WordPair]) {
        self.browseResult = words
    }
    
    func onError(title: String, message: EnfocaError) {
        self.errorTitle = title
        self.errorMessage = message
    }
}
