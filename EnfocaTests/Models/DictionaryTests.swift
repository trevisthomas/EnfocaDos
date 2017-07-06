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
        
//        UserDictionary(
        
        let sut = UserDictionary(dictionaryId: "00-00-000", userRef: "00-10-1111", enfocaRef: "8-1-2-3", termTitle: "Jokes", definitionTitle: "Punchlines", subject: "LOLz", language: "en", conch: "0-11-22-33", countWordPairs: 5, countTags: 10, countAssociations: 15, countMeta: 20)
        
        let json = sut.toJson();
        
        let copy = UserDictionary(json: json)
        
        XCTAssertEqual(sut.definitionTitle, copy.definitionTitle)
        XCTAssertEqual(sut.termTitle, copy.termTitle)
        XCTAssertEqual(sut.subject, copy.subject)
        XCTAssertEqual(sut.enfocaRef, copy.enfocaRef)
        XCTAssertEqual(sut.dictionaryId, copy.dictionaryId)
        XCTAssertEqual(sut.userRef, copy.userRef)
        XCTAssertEqual(sut.language, copy.language)
        XCTAssertEqual(sut.conch, "0-11-22-33")
        
        XCTAssertEqual(sut.countWordPairs, 5)
        XCTAssertEqual(sut.countTags, 10)
        XCTAssertEqual(sut.countAssociations, 15)
        XCTAssertEqual(sut.countMeta, 20)
        
    }
    
    func testJson_ShouldGoBothWaysWithOptionals(){
        
        let sut = UserDictionary(dictionaryId: "00-00-000", userRef: "00-10-1111", enfocaRef: "8-1-2-3", termTitle: "Jokes", definitionTitle: "Punchlines", subject: "LOLz")
        
        sut.conch = "0-11-22-33"
        let json = sut.toJson();
        
        let copy = UserDictionary(json: json)
        
        XCTAssertEqual(sut.definitionTitle, copy.definitionTitle)
        XCTAssertEqual(sut.termTitle, copy.termTitle)
        XCTAssertEqual(sut.subject, copy.subject)
        XCTAssertEqual(sut.enfocaRef, copy.enfocaRef)
        XCTAssertEqual(sut.dictionaryId, copy.dictionaryId)
        XCTAssertEqual(sut.userRef, copy.userRef)
        
        XCTAssertEqual(sut.conch, "0-11-22-33")
        XCTAssertEqual(sut.countWordPairs, 0)
        XCTAssertEqual(sut.countMeta, 0)
        XCTAssertEqual(sut.countAssociations, 0)
        XCTAssertEqual(sut.countTags, 0)
    }
    
    func testJson_ShouldUpdateCounts(){
        
        let sut = UserDictionary(dictionaryId: "00-00-000", userRef: "00-10-1111", enfocaRef: "8-1-2-3", termTitle: "Jokes", definitionTitle: "Punchlines", subject: "LOLz")
        
        sut.conch = "0-11-22-33"
        
        sut.applyCountUpdate(countWordPairs: 5, countAssociations: 10, countTags: 15, countMeta: 20)
        
        let json = sut.toJson();
        
        let copy = UserDictionary(json: json)
        
        XCTAssertEqual(sut.definitionTitle, copy.definitionTitle)
        XCTAssertEqual(sut.termTitle, copy.termTitle)
        XCTAssertEqual(sut.subject, copy.subject)
        XCTAssertEqual(sut.enfocaRef, copy.enfocaRef)
        XCTAssertEqual(sut.dictionaryId, copy.dictionaryId)
        XCTAssertEqual(sut.userRef, copy.userRef)
        
        XCTAssertEqual(sut.conch, "0-11-22-33")
        XCTAssertEqual(sut.countWordPairs, 5)
        XCTAssertEqual(sut.countMeta, 20)
        XCTAssertEqual(sut.countAssociations, 10)
        XCTAssertEqual(sut.countTags, 15)
        
    }

}
