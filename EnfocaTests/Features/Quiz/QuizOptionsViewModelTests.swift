//
//  QuizViewModelTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

@testable import Enfoca
import XCTest

class QuizViewModelTests: XCTestCase {
    
    var sut: QuizOptionsViewModel!
    var delegate: MockCardViewControllerDelegate!
    override func setUp() {
        super.setUp()
        
        getAppDelegate().applicationDefaults = MockApplicationDefaults()
        
        delegate = MockCardViewControllerDelegate()
        
    }

    
    func testIncrement_ShouldMax(){
        
        let tag = Tag(tagId: "123", name: "Test Tag")
        tag.addWordPair(WordPair(pairId: "10101", word: "Werd", definition: "Dup"))
        tag.addWordPair(WordPair(pairId: "10102", word: "Yerd", definition: "Doop"))
        tag.addWordPair(WordPair(pairId: "10103", word: "Herd", definition: "Der"))
        
        getAppDelegate().applicationDefaults.quizWordCount = 2
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        
        XCTAssertEqual(sut.wordCount, 2)
        
        
        sut.incrementWordCount()
        
        XCTAssertEqual(sut.wordCount, 3)
        
        
    }
    
    func testInit_ShouldLimitInitCountValueByMaxAvailable() {
        let tag = Tag(tagId: "123", name: "Test Tag")
        tag.addWordPair(WordPair(pairId: "10101", word: "Werd", definition: "Dup"))
        tag.addWordPair(WordPair(pairId: "10102", word: "Yerd", definition: "Doop"))
        tag.addWordPair(WordPair(pairId: "10103", word: "Herd", definition: "Der"))
        
        getAppDelegate().applicationDefaults.quizWordCount = 8
        
        sut = QuizOptionsViewModel(tag: tag, delegate: delegate)
        
        XCTAssertEqual(sut.wordCount, 3)
        
        
        
    }
    
    
   
    
}

class MockCardViewControllerDelegate: CardViewControllerDelegate {
    
    func getRearWord() -> String {
        return ""
    }
    func getFrontWord() -> String {
        return ""
    }
    
    func correct() {
        
    }
    func incorrect(){
        
    }
    
    func getWordPairsForMatching() -> [WordPair] {
        return []
    }
    
    func onError(title: String, message: EnfocaError) {
        
    }
    
    
}

