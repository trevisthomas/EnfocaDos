//
//  QuizViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

@testable import Enfoca
import XCTest

class QuizOptionsViewModelTests: XCTestCase {
    
    var sut: QuizOptionsViewModel!
    var delegate: MockQuizOptionsViewControllerDelegate!
    var mockService: MockWebService!
    
    override func setUp() {
        super.setUp()
        
//        getAppDelegate().applicationDefaults = MockApplicationDefaults()
        mockService = MockWebService()
        getAppDelegate().webService = mockService
        
        mockService.wordPairs = makeWordPairs()
        
        delegate = MockQuizOptionsViewControllerDelegate()
        
        
        
    }

    
    func testIncrement_ShouldMax(){
        
        let tag = setupTags()
        
        getAppDelegate().applicationDefaults.quizWordCount = 2
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        
        XCTAssertEqual(sut.wordCount, 2)
        
        
        sut.incrementWordCount()
        
        XCTAssertEqual(sut.wordCount, 3)
        
        
    }
    
    private func setupTags() -> Tag{
        let tag = Tag(tagId: "123", name: "Test Tag")
        tag.addWordPair(WordPair(pairId: "10101", word: "Werd", definition: "Dup"))
        tag.addWordPair(WordPair(pairId: "10102", word: "Yerd", definition: "Doop"))
        tag.addWordPair(WordPair(pairId: "10103", word: "Herd", definition: "Der"))
        return tag
    }
    
    func testInit_ShouldLimitInitCountValueByMaxAvailable() {
        let tag = setupTags()
        
        getAppDelegate().applicationDefaults.quizWordCount = 8
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        
        XCTAssertEqual(sut.wordCount, 3)
        
    }
    
    func testQuizOptions_ShouldShowWordOnFrontWhenCardSideSetToTerm() {
        let tag = setupTags()
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        
        sut.cardSide = CardSide.term
        
        sut.startQuiz {
            //Should NOT be async in mock service!
        }
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[0].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[0].definition)
        
        
    }
    
    func testQuizOptions_ShouldShowWordOnRearWhenCardSideSetToDefinition() {
        let tag = setupTags()
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        
        sut.cardSide = CardSide.definition
        
        sut.startQuiz {
            //Should NOT be async in mock service!
        }
        
        
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[0].definition)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[0].word)
    }
    
    func testQuizOptions_ShouldShowRamdomOnRearWhenCardSideSetToRandom() {
        let tag = setupTags()
        
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        sut.cardSide = CardSide.random
        sut.startQuiz {}
        
        let previous = sut.getRearWord()
        
        for _ in 0...10 {
            sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
            sut.cardSide = CardSide.random
            sut.startQuiz {}
            
            if sut.getRearWord() != previous {
                XCTAssertTrue(true)
                return
            }
        }
        
        XCTFail("10 random tries never changed")
    }
    
    func testQuizOptions_ShouldShowReviewWhenThresholdReached() {
        let tag = setupTags()
        
        getAppDelegate().applicationDefaults.numberOfIncorrectAnswersTillReview = 2
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        sut.cardSide = .term
        sut.startQuiz {
            //Should NOT be async in mock service!
        }
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[0].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[0].definition)
        
        sut.incorrect()
        XCTAssertFalse(sut.isTimeForMatchingRound())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[1].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[1].definition)
        
        sut.incorrect()
        XCTAssertTrue(sut.isTimeForMatchingRound())
        
        //
        
        XCTAssertEqual(sut.getWordPairsForMatchingRound()[0], mockService.wordPairs[0])
        XCTAssertEqual(sut.getWordPairsForMatchingRound()[1], mockService.wordPairs[1])
        
        
        //
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[2].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[2].definition)
        
        sut.incorrect()
        XCTAssertFalse(sut.isTimeForMatchingRound())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[3].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[3].definition)
        
        sut.incorrect()
        XCTAssertTrue(sut.isTimeForMatchingRound())
        XCTAssertEqual(sut.getWordPairsForMatchingRound()[0], mockService.wordPairs[2])
        XCTAssertEqual(sut.getWordPairsForMatchingRound()[1], mockService.wordPairs[3])
        
    }
    
    func testQuizOptions_ShouldOnlyShowReviewWhenThresholdReached() {
        let tag = setupTags()
        
        getAppDelegate().applicationDefaults.numberOfIncorrectAnswersTillReview = 2
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        sut.cardSide = .term
        sut.startQuiz {
            //Should NOT be async in mock service!
        }
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[0].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[0].definition)
        
        sut.correct()
        XCTAssertFalse(sut.isTimeForMatchingRound())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[1].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[1].definition)
        
        sut.incorrect()
        XCTAssertFalse(sut.isTimeForMatchingRound())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[2].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[2].definition)
        
        sut.incorrect()
        XCTAssertTrue(sut.isTimeForMatchingRound())
        
        
    }

    
    func testQuizOptions_ShouldSayThatItIsFinishedAndSuggestRetry(){
        let tag = setupTags()
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        sut.cardSide = .term
        sut.startQuiz {}
        
        XCTAssertEqual(sut.quizWords.count, 4)
        
        sut.correct()
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        sut.correct()
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        sut.correct()
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        sut.correct()
        XCTAssertTrue(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
    }
    
    func testQuizOptions_ShouldBeFinishedAndNotSuggestReview() {
        
        let tag = setupTags()
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        sut.cardSide = .term
        sut.startQuiz {}
        
        XCTAssertEqual(sut.quizWords.count, 4)
        
        sut.correct()
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        sut.incorrect()
        XCTAssertFalse(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.incorrect()
        XCTAssertFalse(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.incorrect()
        XCTAssertTrue(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.retry(shuffle: false)
        XCTAssertEqual(sut.quizWords.count, 3)
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[1].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[1].definition)
    }
    
    func testQuizOptions_ReviewShouldHaveAllIncorrectWords() {
        
        let tag = setupTags()
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        sut.cardSide = .term
        sut.startQuiz {}
        
        XCTAssertEqual(sut.quizWords.count, 4)
        
        sut.correct()
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        sut.incorrect()
        XCTAssertFalse(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.incorrect()
        XCTAssertFalse(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.incorrect()
        XCTAssertTrue(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.retry(shuffle: false)
        XCTAssertEqual(sut.quizWords.count, 3)
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[1].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[1].definition)
        
        sut.incorrect()
        XCTAssertFalse(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[2].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[2].definition)
        
        sut.correct()
        XCTAssertFalse(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[3].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[3].definition)
        
        sut.correct()
        XCTAssertTrue(sut.isFinished())
        XCTAssertTrue(sut.isRetrySuggested())
        
        sut.retry(shuffle: false)
        XCTAssertEqual(sut.quizWords.count, 1)
        XCTAssertFalse(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
        
        XCTAssertEqual(sut.getFrontWord(), mockService.wordPairs[1].word)
        XCTAssertEqual(sut.getRearWord(), mockService.wordPairs[1].definition)
        
        sut.correct()
        XCTAssertTrue(sut.isFinished())
        XCTAssertFalse(sut.isRetrySuggested())
    }
    
    
    //TODO! Check which words are being reviewed!
}

class MockQuizOptionsViewControllerDelegate: QuizOptionsViewControllerDelegate {
    func onError(title: String, message: EnfocaError) {
        
    }
}

