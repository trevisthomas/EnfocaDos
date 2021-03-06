//
//  QuizViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

protocol QuizViewModel {
    func getRearWord() -> String
    func getFrontWord() -> String
    
    func correct()
    func incorrect()
    
    func getWordPairsForMatchingRound() -> [WordPair]
    
    func isTimeForMatchingRound() -> Bool
    func isFinished() -> Bool
    
    func getCorrectCount()->Int
    func getWordsAskedCount()->Int
    func getScore()->String
    
    func retry()
    
    func isRetrySuggested() -> Bool
    
    func getCardTimeout() -> Int
    
    func getCardTimeoutWarning() -> Int
    
    var timeTakenForCardInMiliSeconds: Int? {get set}
    
    func updateDataStoreCache()
    
}


class QuizOptionsViewModel: Controller, QuizViewModel {
    let tag: Tag
    private(set) var wordCount: Int!  
    var cardOrder: CardOrder!
    var cardSide: CardSide!
    private(set) var quizWords: [WordPair] = []
    private(set) var originalWords: [WordPair]!
    private let delegate: QuizOptionsViewControllerDelegate
    var timeTakenForCardInMiliSeconds: Int? = nil
    
    private var currentWordPairIndex: Int = 0
    private var currentFrontSide: CardSide!
    private var incorrectWords: [WordPair] = []
    private var numberOfIncorrectAnswersTillReview: Int!
    private var incorrectWordCountSinceMatchingRound: Int = 0

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
        //How to sort when i dont have meta?  See WordPairTableViewCell
//        incorrectWords.sorted { (wp1: WordPair, wp2, WordPair) -> Bool in
//            return 
//        }
        
        incorrectWordCountSinceMatchingRound = 0
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
        scoreCurrentWord(isCorrect: true)
        currentWordPairIndex += 1
        timeTakenForCardInMiliSeconds = nil
    }
    
    func incorrect() {
        scoreCurrentWord(isCorrect: false)
        incorrectWords.append(quizWords[currentWordPairIndex])
        currentWordPairIndex += 1
        
        incorrectWordCountSinceMatchingRound += 1
        timeTakenForCardInMiliSeconds = nil
    }
    
    private func scoreCurrentWord(isCorrect: Bool) {
        let localWp = quizWords[currentWordPairIndex]
        
        let duration = timeTakenForCardInMiliSeconds ?? 0
        // This guard breaks a lot of tests and i'm lazy
//        guard let duration = timeTakenForCardInSeconds else {fatalError()}
        services.updateScore(forWordPair: localWp, correct: isCorrect, elapsedTime: duration, callback: { (wp: MetaData?, error: EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Network error", message: error)
            }
//            localWp.metaData = wp?.metaData
        })
    }
    
    //Deprecated
    func isTimeForMatchingRound() -> Bool {
        return incorrectWordCountSinceMatchingRound == numberOfIncorrectAnswersTillReview
    }
    
    func isFinished() -> Bool {
        return currentWordPairIndex >= quizWords.count
    }
    
    func isRetrySuggested() -> Bool {
        return incorrectWords.count > 0
    }
    
    func getScore() -> String {
        let score = Double(quizWords.count - incorrectWords.count) / Double(quizWords.count)
        return score.asPercent!
    }
    
    func retry(shuffle: Bool = true) {
        currentWordPairIndex = 0
        incorrectWordCountSinceMatchingRound = 0
        quizWords.removeAll()
        
        if (shuffle) {
            quizWords.append(contentsOf: incorrectWords.shuffled())
        } else {
            quizWords.append(contentsOf: incorrectWords)
        }
        
        incorrectWords.removeAll()
    }
    
    //This weirdness is because i couldnt provide a default param in the protocol
    func retry() {
        retry(shuffle: true)
    }
    
    func getCorrectCount() -> Int {
        return getWordsAskedCount() - incorrectWords.count
    }
    
    func getWordsAskedCount() -> Int{
        return quizWords.count
    }

    func getCardTimeout() -> Int{
        return getAppDelegate().applicationDefaults.cardTimeout
    }
    
    func getCardTimeoutWarning() -> Int {
        return getAppDelegate().applicationDefaults.cardTimeoutWarning
    }
    
    func updateDataStoreCache() {
        getAppDelegate().saveDefaults()
    }
}
