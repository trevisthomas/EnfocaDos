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
        
        sut = HomeController(delegate: delegate)
    }
    
    func testFetchTags_ShouldBeLoadedIntoDelegate(){
        sut.startup()
        XCTAssertEqual(services.fetchUserTagsCallCount, 1)
        XCTAssertEqual(delegate.loadedTags!, services.tags)
    }
    
    func testFetchTags_ShouldFailWithError(){
        services.fetchUserTagsError = "Failed To Load"
        sut.startup()
        
        XCTAssertEqual(services.fetchUserTagsCallCount, 1)
        XCTAssertEqual(delegate.errorMessage, services.fetchUserTagsError)
        XCTAssertEqual(delegate.errorTitle, "Error fetching tags")
        XCTAssertNil(delegate.loadedTags)
    }
}

class MockHomeControllerDelegate : HomeControllerDelegate {
    var errorTitle: String?
    var errorMessage: EnfocaError?
    var loadedTags: [Tag]?
    
    func onError(title: String, message: EnfocaError) {
        errorTitle = title
        errorMessage = message
    }
    
    func onTagsLoaded(tags: [Tag]) {
        self.loadedTags = tags
    }
}


