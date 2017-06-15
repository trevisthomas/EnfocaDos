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
    var delegate : MockMatchingRoundViewModelDelegate!
    override func setUp() {
        super.setUp()
        wordPairs = makeWordPairs()
        delegate = MockMatchingRoundViewModelDelegate()
        
        sut = MatchingRoundViewModel(delegate: delegate, wordPairs: wordPairs)
        
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
    
    func testMatchingPairs_ShouldNotChangeSelectionOfHidden(){
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        sut.selectPair(cardSide: .term, atRow: 0)
        
        XCTAssertEqual(delegate.reloadCalledCount, 2)
        
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .hidden)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)

        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .normal)
        
//        XCTAssertTrue(delegate.removed.contains(where: { (removed:
//            MatchingRoundViewModelTests.Removed) -> Bool in
//            return removed.cellRemovedAtRow == 0 &&
//            removed.cellRemovedCardSide == CardSide.definition
//        }))
//        
//        XCTAssertTrue(delegate.removed.contains(where: { (removed:
//            MatchingRoundViewModelTests.Removed) -> Bool in
//            return removed.cellRemovedAtRow == 0 &&
//                removed.cellRemovedCardSide == CardSide.term
//        }))

    }
    
    
    func testMatchingPairs_ShouldRemoveHiddenCells(){
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        sut.selectPair(cardSide: .term, atRow: 0)
        
        XCTAssertEqual(delegate.reloadCalledCount, 2)
        
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .hidden)
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        XCTAssertEqual(delegate.reloadCalledCount, 3)
        
        
        
        XCTAssertEqual(wordPairs.count, 4)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .normal)
        
        
        
    }
    
    func testMatchingPairs_ShouldHideOnCorrect(){
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        sut.selectPair(cardSide: .term, atRow: 0)
        XCTAssertEqual(delegate.reloadCalledCount, 2)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .hidden)
        
        sut.selectPair(cardSide: .term, atRow: 1)
        XCTAssertEqual(delegate.reloadCalledCount, 3)
        
        XCTAssertEqual(wordPairs.count, 4)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .hidden)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .disabled)
        
        sut.selectPair(cardSide: .term, atRow: 1)
        XCTAssertEqual(delegate.reloadCalledCount, 4)
    }
    
    func testMatchingPairs_DoubleTapShouldClearSeletion(){
        
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        
        XCTAssertEqual(wordPairs.count, 4)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .disabled)
        
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .normal)
        
        XCTAssertEqual(delegate.reloadCalledCount, 2)
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .disabled)
        
        
    }
    
    func testMatchingPairs_SelectingTwoFromTheSameSectionShouldJustChangeTheSelection(){
        
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        
        XCTAssertEqual(wordPairs.count, 4)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .disabled)
        
        
        sut.selectPair(cardSide: .definition, atRow: 1)
        
        XCTAssertEqual(delegate.reloadCalledCount, 2)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .disabled)
    }
    
    func testMatchingPairs_ShouldResetStateWhenWrongAnswerEvenAfterSomeSelections(){
        
        
        sut.selectPair(cardSide: .definition, atRow: 0)
        
        XCTAssertEqual(wordPairs.count, 4)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .disabled)
        
        
        sut.selectPair(cardSide: .definition, atRow: 1)
        
        XCTAssertEqual(delegate.reloadCalledCount, 2)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .selected)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .disabled)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .disabled)
        
        sut.selectPair(cardSide: .term, atRow: 0) //Wrong answer, shoud deselect all
        
        XCTAssertEqual(delegate.reloadCalledCount, 3)
        
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .definition, atRow: 3).state, .normal)
        
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 0).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 1).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 2).state, .normal)
        XCTAssertEqual(sut.getPair(cardSide: .term, atRow: 3).state, .normal)
        
        
        
        
        
    }
    
    
    

}

extension MatchingRoundViewModelTests {
    
    class Removed{
        var cellRemovedCardSide: CardSide?
        var cellRemovedAtRow: Int?
        
        init(cardSide: CardSide, atRow: Int) {
            cellRemovedAtRow = atRow
            cellRemovedCardSide = cardSide
        }
    }
    
    class MockMatchingRoundViewModelDelegate: MatchingRoundViewModelDelegate {
        var reloadCalledCount = 0
        func reloadMatchingPairs() {
            reloadCalledCount += 1
        }
        
        var removed: [Removed] = []
        func removeCell(cardSide: CardSide, atRow: Int) {
            removed.append(Removed(cardSide: cardSide, atRow: atRow))
        }
    }
}
