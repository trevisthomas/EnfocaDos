//
//  WordPairTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class WordPairTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldBeInitialized(){
        
        let d = Date()
        let wp = WordPair(pairId: "guid", word: "hello", definition: "hola", dateCreated: d )
        
        XCTAssertEqual(wp.pairId, "guid")
        XCTAssertEqual(wp.word, "hello")
        XCTAssertEqual(wp.definition, "hola")
        XCTAssertEqual(wp.dateCreated, d)
        
    }
    
    func testEquals_ShouldBeEqual(){
        let d = Date()
        let wp1 = WordPair(pairId: "1234", word: "hello", definition: "hola", dateCreated: d )
        let wp2 = WordPair(pairId: "1234", word: "hello dont care", definition: "nope", dateCreated: d )
        
        XCTAssertTrue(wp1 == wp2) //Only compared field is the pairId
    }
    
    func testIsEqualsNSCodingStyle_ShouldBeEqual(){
        let d = Date()
        let wp1 = WordPair(pairId: "1234", word: "hello", definition: "hola", dateCreated: d )
        let wp2 = WordPair(pairId: "1234", word: "hello dont care", definition: "nope", dateCreated: d )
        
        let a1 = [wp1]
        let a2 = [wp2]
        
        //This nightmare situatuation is because NSCoding says that it is equatable compliant but it will not call your == override. 
        //
        XCTAssertEqual(a1, a2)
    }
    
    func testEquals_ShouldNotBeEqual(){
        let d = Date()
        let wp1 = WordPair(pairId: "1234", word: "hello", definition: "hola", dateCreated: d )
        let wp2 = WordPair(pairId: "4321", word: "hello dont care", definition: "nope", dateCreated: d )
        
        XCTAssertFalse(wp1 == wp2) //Only compared field is the pairId
    }
    
    func testTags_ShouldSort(){
        let d = Date()
        let wp1 = WordPair(pairId: "1234", word: "hello", definition: "hola", dateCreated: d )
        
        wp1.addTag(Tag(name: "def"))
        wp1.addTag(Tag(name: "abc"))
        
        XCTAssertEqual(wp1.tags.tagsToText(), "abc, def")
        
        wp1.addTag(Tag(name: "DAB"))
        
        XCTAssertEqual(wp1.tags.tagsToText(), "abc, DAB, def")
        
    }
    
}
