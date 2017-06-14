//
//  MatchingRoundViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

enum MatchingQuizState {
    case selected
    case hidden
    case normal
}

class MatchingPair {
    let wordPair: WordPair
    let cardSide: CardSide
    
    var state: MatchingQuizState
    
    var title : String {
        get {
            return cardSide == .definition ? wordPair.definition : wordPair.word
        }
    }
    
    init(wordPair: WordPair, cardSide: CardSide){
        self.wordPair = wordPair
        self.state = .normal
        self.cardSide = cardSide
    }
}

class MatchingRoundViewModel {
    private(set) var matchingPairs : [MatchingPair] = []
    
    init(wordPairs: [WordPair]) {
        for wp in wordPairs {
            matchingPairs.append(MatchingPair(wordPair: wp, cardSide: .term))
        }
        
        for wp in wordPairs {
            matchingPairs.append(MatchingPair(wordPair: wp, cardSide: .definition))
        }
    }
    
    func getPair(cardSide: CardSide, atRow: Int) -> MatchingPair {
        switch cardSide {
        case .term:
            return matchingPairs[atRow]
        case .definition:
            return matchingPairs[atRow + matchingPairs.count / 2]
        default: fatalError()
        }
    }
    
}
