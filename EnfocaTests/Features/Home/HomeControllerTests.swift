//
//  HomeControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class HomeControllerTests: XCTestCase {
    var sut : HomeController!
    var delegate : MockHomeControllerDelegate!
    var services : MockWebService!
    
    override func setUp() {
        super.setUp()
        delegate = MockHomeControllerDelegate()
        services = MockWebService()
        getAppDelegate().webService = services
        
        
    }
    
    func testFetchTags_ShouldBeLoadedIntoDelegate(){
        sut = HomeController(delegate: delegate)
        
        sut.initialize()
        
        XCTAssertEqual(services.fetchUserTagsCallCount, 1)
        XCTAssertEqual(delegate.loadedTags!, services.tags)
    }
    
    func testFetchTags_ShouldFailWithError(){
        services.fetchUserTagsError = "Failed To Load"

        sut = HomeController(delegate: delegate)
        sut.initialize()
        
        XCTAssertEqual(services.fetchUserTagsCallCount, 1)
        XCTAssertEqual(delegate.errorMessage, services.fetchUserTagsError)
        XCTAssertEqual(delegate.errorTitle, "Error fetching tags")
        XCTAssertNil(delegate.loadedTags)
    }
    
    func testSearch_ShouldMakeServiceCallAndNotifyDelegate(){
        sut = HomeController(delegate: delegate)
        sut.initialize()
        
        sut.wordOrder = WordPairOrder.definitionAsc
        
        XCTAssertEqual(services.fetchWordPairCallCount, 0)
        
        sut.phrase = "any"
        
        XCTAssertEqual(services.fetchWordPairCallCount, 1)
        XCTAssertEqual(services.fetchWordPairPattern, "any")
        XCTAssertEqual(services.fetchWordPairOrder, WordPairOrder.definitionAsc)
        
        XCTAssertEqual(delegate.searchResults!, services.wordPairs)
    }
}

class MockHomeControllerDelegate : HomeControllerDelegate {
    var errorTitle: String?
    var errorMessage: EnfocaError?
    var loadedTags: [Tag]?
    var searchResults: [WordPair]?
    var wordOrderChangedCount: Int = 0
    
    func onError(title: String, message: EnfocaError) {
        errorTitle = title
        errorMessage = message
    }
    
    func onTagsLoaded(tags: [Tag]) {
        self.loadedTags = tags
    }
    
    func onSearchResults(words: [WordPair]) {
        self.searchResults = words
    }
    
    func onWordPairOrderChanged() {
        wordOrderChangedCount = wordOrderChangedCount + 1
    }
}


