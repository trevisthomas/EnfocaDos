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
        
        XCTAssertTrue(sut.isEditMode())
        XCTAssertEqual(sut.title(), "Edit")
    }
}

private class MockEditWordPairControllerDelegate: EditWordPairControllerDelegate {
    
}
