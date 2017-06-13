//
//  QuizViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation



class QuizOptionsViewModel: Controller {
    private let tag: Tag
    private(set) var wordCount: Int!  
    var cardOrder: CardOrder!
    var cardSide: CardSide!
    private(set) var quizWords: [WordPair]!
    private let delegate: CardViewControllerDelegate
    
    var tagName: String {
        get {
            return tag.name
        }
    }
    
    init(tag: Tag, delegate: CardViewControllerDelegate) {
        self.tag = tag
        self.delegate = delegate
        wordCount = appDefaults.quizWordCount
        
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
    
    func startQuiz(callback: ()->()){
        services.fetchQuiz(forTag: tag, cardOrder: cardOrder, wordCount: wordCount) { (wordPairs: [WordPair]?, error: EnfocaError?) in
            
            if let error = error { self.delegate.onError(title: "Failed to load quiz words", message: error) }
            
            guard let wordPairs = wordPairs else { fatalError() }
            
            self.quizWords = wordPairs
        }
    }
    
    
    func getCurrentIncorrectWordPairs() -> [WordPair] {
        return quizWords  //Just for now
    }
    
}
