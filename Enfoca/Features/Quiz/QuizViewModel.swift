//
//  QuizViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class QuizViewModel: Controller {
    private let tag: Tag
    private(set) var wordCount: Int!  
    var cardOrder: CardOrder!
    var cardSide: CardSide!
    
    var tagName: String {
        get {
            return tag.name
        }
    }
    
    init(tag: Tag) {
        self.tag = tag
        
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
    
    
}
