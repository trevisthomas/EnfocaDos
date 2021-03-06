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
        sut.reloadTags()
        
        XCTAssertEqual(services.fetchUserTagsCallCount, 1)
        //Loaded tags no longer match the service tags because of any and none.  I didnt put a real update here beecause for this test the list was empty anyway.
//        XCTAssertEqual(delegate.loadedTags!, services.tags)
    }
    
    func testFetchTags_ShouldFailWithError(){
        services.fetchUserTagsError = "Failed To Load"

        sut = HomeController(delegate: delegate)
        sut.initialize()
        sut.reloadTags()
        
        XCTAssertEqual(services.fetchUserTagsCallCount, 1)
        XCTAssertEqual(delegate.errorMessage, services.fetchUserTagsError)
        XCTAssertEqual(delegate.errorTitle, "Error fetching tags")
        XCTAssertNil(delegate.loadedTags)
    }
    
    func testSearch_ShouldMakeServiceCallAndNotifyDelegate(){
        sut = HomeController(delegate: delegate)
        sut.initialize()
        sut.reloadTags()
        
        sut.wordOrder = WordPairOrder.definitionAsc
        
        XCTAssertEqual(services.fetchWordPairCallCount, 2)
        
        sut.phrase = "any"
        
        XCTAssertEqual(services.fetchWordPairCallCount, 3)
        XCTAssertEqual(services.fetchWordPairPattern, "\\bany")
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


