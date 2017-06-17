//
//  QuizViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class QuizOptionsViewModel: Controller, QuizViewModel {
    private let tag: Tag
    private(set) var wordCount: Int!  
    var cardOrder: CardOrder!
    var cardSide: CardSide!
    private(set) var quizWords: [WordPair] = []
    private(set) var originalWords: [WordPair]!
    private let delegate: QuizOptionsViewControllerDelegate
    
    private var currentWordPairIndex: Int = 0
    private var currentFrontSide: CardSide!
    private var incorrectWords: [WordPair] = []
    private var numberOfIncorrectAnswersTillReview: Int!

    var tagName: String {
        get {
            return tag.name
        }
    }
    
    init(tag: Tag, delegate: QuizOptionsViewControllerDelegate) {
        self.tag = tag
        self.delegate = delegate
        wordCount = appDefaults.quizWordCount
        numberOfIncorrectAnswersTillReview = appDefaults.numberOfIncorrectAnswersTillReview
        
        if wordCount > tag.count {
            wordCount = tag.count
        }
        
        cardOrder = appDefaults.cardOrder
        cardSide = appDefaults.cardSide
    }
    
    
    func onEvent(event: Event) {
        
    }
    
    func incrementWordCount() {
        wordCount = wordCount * 2
        
        if wordCount > tag.wordPairs.count {
            wordCount = tag.wordPairs.count
        }
    }
    
    func decrementWordCount() {
        wordCount = wordCount / 2
        if wordCount < 2 {
            wordCount = 2
        }
        
        if 2 > tag.wordPairs.count {
            wordCount = tag.wordPairs.count
        }
    }
    
    func startQuiz(callback: @escaping ()->()){
        services.fetchQuiz(forTag: tag, cardOrder: cardOrder, wordCount: wordCount) { (wordPairs: [WordPair]?, error: EnfocaError?) in
            
            if let error = error { self.delegate.onError(title: "Failed to load quiz words", message: error) }
            
            guard let wordPairs = wordPairs else { fatalError() }
            
            self.originalWords = wordPairs
            self.quizWords.append(contentsOf: self.originalWords)
            
            self.adjustCurrentFrontSide()
            
            callback()
        }
    }
    
    private func adjustCurrentFrontSide() {
        if cardSide == .random{
            currentFrontSide = Randomizer.randomBool() ? CardSide.term : CardSide.definition
        } else {
            currentFrontSide = cardSide
        }
// Why on earth did this not compile?
//        switch (cardSide) {
//        case CardSide.random:
//            currentFrontSide = Randomizer.randomBool() ? CardSide.term : CardSide.definition
//        case CardSide.term, CardSide.definition:
//            currentFrontSide = cardSide
//            
//        }
    }
    
    
    
    func getWordPairsForMatchingRound() -> [WordPair] {
        return Array(incorrectWords.suffix(numberOfIncorrectAnswersTillReview))
    
    }
    
    func getRearWord() -> String {
        if currentFrontSide == CardSide.term {
            return quizWords[currentWordPairIndex].definition
        } else {
            return quizWords[currentWordPairIndex].word
        }
    }
    
    func getFrontWord() -> String {
        if currentFrontSide == CardSide.definition {
            return quizWords[currentWordPairIndex].definition
        } else {
            return quizWords[currentWordPairIndex].word
        }
    }
    
    func correct() {
        currentWordPairIndex += 1
    }
    
    func incorrect() {
        incorrectWords.append(quizWords[currentWordPairIndex])
        currentWordPairIndex += 1
    }
    
    func isTimeForMatchingRound() -> Bool {
        guard incorrectWords.count > 0 else { return false }
        return incorrectWords.count % numberOfIncorrectAnswersTillReview == 0
    }
    
    func isFinished() -> Bool {
        return currentWordPairIndex >= quizWords.count
    }
    
    func isRetrySuggested() -> Bool {
        return incorrectWords.count > 0
    }
    
    func retry(shuffle: Bool = true) {
        currentWordPairIndex = 0
        quizWords.removeAll()
        quizWords.append(contentsOf: incorrectWords)
        incorrectWords.removeAll()
        
        if (shuffle) {
            fatalError()
        }
    }

}
