//
//  MetaDataTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca
class MetaDataTests: XCTestCase {
    
    var dateUpdated : Date!
    var dateCreated : Date!
    
    override func setUp() {
        super.setUp()
        dateUpdated = JsonDateFormatter.instance.date(from: "2016-12-21 21:49:40")!
        dateCreated = JsonDateFormatter.instance.date(from: "2016-03-11 00:31:20")!
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInit_ShouldBeInitialized(){
        
        let meta = MetaData(metaId: "guid", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: 5, totalTime: 1234, timedViewCount: 8)
        
        
        XCTAssertEqual(meta.metaId, "guid")
        XCTAssertEqual(meta.pairId, "pairGuid")
        
        XCTAssertEqual(meta.dateUpdated, dateUpdated)
        XCTAssertEqual(meta.dateCreated, dateCreated)
        XCTAssertEqual(meta.incorrectCount, 5)
        XCTAssertEqual(meta.totalTime, 1234)
        XCTAssertEqual(meta.timedViewCount, 8)
    }
    
    func testEquals_ShouldBeEqual(){
        let meta = MetaData(metaId: "guid", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: 5, totalTime: 1234, timedViewCount: 8)
        
        let meta2 = MetaData(metaId: "guid", pairId: "garbage", dateCreated: Date(), dateUpdated: Date(), incorrectCount: 100, totalTime: 555, timedViewCount: 1)
        
        XCTAssertTrue(meta == meta2) //Only compared field is the metaId
    }
    
    func testEquals_ShouldNotBeEqual(){
        let meta = MetaData(metaId: "guid", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: 5, totalTime: 1234, timedViewCount: 8)
        
        let meta2 = MetaData(metaId: "guid-diff", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: 5, totalTime: 1234, timedViewCount: 8)
        
        XCTAssertFalse(meta == meta2) //Only compared field is the metaId
    }
    
    func testCalulated_ShouldBeAccurate(){
        let meta = MetaData(metaId: "guid", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: 5, totalTime: 100, timedViewCount: 20)
        
        XCTAssertEqual(meta.averageTime, 5)
        XCTAssertEqual(meta.score, 0.75)
        XCTAssertEqual(meta.scoreAsString, "75%")
    }
    
    func testJson_ShouldSerializeAndDeserialize(){
        let meta = MetaData(metaId: "guid", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: 5, totalTime: 100, timedViewCount: 20)
        
        let json = meta.toJson()
        
        let meta2 = MetaData(json: json)
        
        XCTAssertEqual(meta.pairId, meta2.pairId)
        XCTAssertEqual(meta.metaId, meta2.metaId)
        XCTAssertEqual(meta.dateCreated, meta2.dateCreated)
        XCTAssertEqual(meta.dateUpdated, meta2.dateUpdated)
        XCTAssertEqual(meta.timedViewCount, meta2.timedViewCount)
        XCTAssertEqual(meta.totalTime, meta2.totalTime)
        XCTAssertEqual(meta.incorrectCount, meta2.incorrectCount)
    }
    
    func testJson_ShouldSerializeAndDeserializeWithNilUpdatedDate(){
        let meta = MetaData(metaId: "guid", pairId: "pairGuid", dateCreated: dateCreated, dateUpdated: nil, incorrectCount: 5, totalTime: 100, timedViewCount: 20)
        
        let json = meta.toJson()
        
        let meta2 = MetaData(json: json)
        
        XCTAssertEqual(meta.pairId, meta2.pairId)
        XCTAssertEqual(meta.metaId, meta2.metaId)
        XCTAssertEqual(meta.dateCreated, meta2.dateCreated)
        XCTAssertEqual(meta.dateUpdated, meta2.dateUpdated)
        XCTAssertEqual(meta.timedViewCount, meta2.timedViewCount)
        XCTAssertEqual(meta.totalTime, meta2.totalTime)
        XCTAssertEqual(meta.incorrectCount, meta2.incorrectCount)
    }
    
}
