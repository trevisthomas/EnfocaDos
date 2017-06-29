//
//  WordPairEditorControllerTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class EditWordPairControllerTests: XCTestCase {
    private var sut : EditWordPairController!
    private var delegate : MockEditWordPairControllerDelegate!
    private var services : MockWebService!
    
    override func setUp() {
        super.setUp()
        delegate = MockEditWordPairControllerDelegate()
        services = MockWebService()
        getAppDelegate().webService = services
    }
    
    func testInit_ShouldInitialize(){
        let wp = WordPair(pairId: "0010", word: "Enfoca", definition: "Focus")
        
        sut = EditWordPairController(delegate: delegate, wordPair: wp)
        
        XCTAssertTrue(sut.isEditMode)
        XCTAssertEqual(sut.title(), "Edit")
    }
    
    func testAvgTime_ShouldCalculateAverage() {
        let wp = WordPair(pairId: "0010", word: "Enfoca", definition: "Focus" )
        let meta = MetaData(metaId: "01", pairId: wp.pairId, dateCreated: Date(), dateUpdated: Date(), incorrectCount: 1, totalTime: 90000, timedViewCount: 9)
        services.metaDict[wp.pairId] = meta
        
        sut = EditWordPairController(delegate: delegate, wordPair: wp)
        
        sut.initialize()

        XCTAssertEqual(sut.getAverageTime(), "10.0 seconds.")
    }
}

private class MockEditWordPairControllerDelegate: EditWordPairControllerDelegate {
    func onTagsLoaded(tags: [Tag], selectedTags: [Tag]) {
        
    }
    
    func onError(title: String, message: EnfocaError) {
        
    }
    
    func onUpdate() {
        
    }
    
    func dismissViewController() {
        
    }
}
