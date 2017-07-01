//
//  DictionaryTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class DictionaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testJson_ShouldGoBothWays(){
        
        let sut = UserDictionary(dictionaryId: "00-00-000", userRef: "00-10-1111", enfocaRef: "8-1-2-3", termTitle: "Jokes", definitionTitle: "Punchlines", subject: "LOLz", language: "en")
        
        let json = sut.toJson();
        
        let copy = UserDictionary(json: json)
        
        XCTAssertEqual(sut.definitionTitle, copy.definitionTitle)
        XCTAssertEqual(sut.termTitle, copy.termTitle)
        XCTAssertEqual(sut.subject, copy.subject)
        XCTAssertEqual(sut.enfocaRef, copy.enfocaRef)
        XCTAssertEqual(sut.dictionaryId, copy.dictionaryId)
        XCTAssertEqual(sut.userRef, copy.userRef)
        XCTAssertEqual(sut.language, copy.language)
        
    }
    
    func testJson_ShouldGoBothWaysWithOptionals(){
        
        let sut = UserDictionary(dictionaryId: "00-00-000", userRef: "00-10-1111", enfocaRef: "8-1-2-3", termTitle: "Jokes", definitionTitle: "Punchlines", subject: "LOLz")
        
        let json = sut.toJson();
        
        let copy = UserDictionary(json: json)
        
        XCTAssertEqual(sut.definitionTitle, copy.definitionTitle)
        XCTAssertEqual(sut.termTitle, copy.termTitle)
        XCTAssertEqual(sut.subject, copy.subject)
        XCTAssertEqual(sut.enfocaRef, copy.enfocaRef)
        XCTAssertEqual(sut.dictionaryId, copy.dictionaryId)
        XCTAssertEqual(sut.userRef, copy.userRef)
        
    }

}
