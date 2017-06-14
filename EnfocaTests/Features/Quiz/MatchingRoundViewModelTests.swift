//
//  MatchingRoundViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class MatchingRoundViewModelTests: XCTestCase {
    
    var sut : MatchingRoundViewModel!
    var wordPairs: [WordPair]!
    override func setUp() {
        super.setUp()
        wordPairs = makeWordPairs()
        sut = MatchingRoundViewModel(wordPairs: wordPairs)
    }
    
    func testInit_ShouldInit(){
        XCTAssertEqual(sut.matchingPairs.count, wordPairs.count * 2)
        
        var wordTotal: Int = 0
        var definitionTotal: Int = 0
        for mp in sut.matchingPairs {
            
            if mp.cardSide == .definition {
                definitionTotal += 1
            }
            else {
                wordTotal += 1
            }
        }
        
        XCTAssertEqual(wordTotal, wordPairs.count)
        XCTAssertEqual(definitionTotal, wordPairs.count)
    }
    
    func testMatchingPairs_ShouldLoadCorrectPairs(){
        var mp = sut.getPair(cardSide: CardSide.definition, atRow: 0)
        XCTAssertEqual(mp.title , "Espanol")
        
        mp = sut.getPair(cardSide: CardSide.term, atRow: 0)
        XCTAssertEqual(mp.title , "English")

        
    }
}
