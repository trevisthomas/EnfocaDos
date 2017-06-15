//
//  MatchingRoundViewModel.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

protocol MatchingRoundViewModelDelegate {
    func reloadMatchingPairs()
    func removeCell(cardSide: CardSide, atRow: Int)
// animateIncorrect
//    animateCorrect
}

class MatchingRoundViewModel {
    private(set) var matchingPairs : [MatchingPair] = []
    var previousSelection : MatchingPair?
    
    private let delegate: MatchingRoundViewModelDelegate
    
    init(delegate: MatchingRoundViewModelDelegate, wordPairs: [WordPair]) {
        self.delegate = delegate
        for wp in wordPairs {
            matchingPairs.append(MatchingPair(wordPair: wp, cardSide: .term))
        }
        
        for wp in wordPairs {
            matchingPairs.append(MatchingPair(wordPair: wp, cardSide: .definition))
        }
    }
    
//    func getPairShuffled(cardSide: CardSide, atRow: Int) -> MatchingPair {
//        
//    }
    
    func getPair(cardSide: CardSide, atRow: Int) -> MatchingPair {
        
        if atRow >= matchingPairs.count / 2 {
            fatalError()
        }
        
        switch cardSide {
        case .term:
            return matchingPairs[atRow]
        case .definition:
            return matchingPairs[atRow + matchingPairs.count / 2]
        default: fatalError()
        }
    }
    
    
    func selectPair(cardSide: CardSide, atRow: Int) {
        
        if let previousSelection = previousSelection {
            //Score
            let currentSelection = performDeselect(cardSide: cardSide, atRow: atRow)
            if previousSelection === currentSelection {
//                previousSelection.state = .normal
//                currentSelection.state = .normal
                
                self.previousSelection = nil
                
                delegate.reloadMatchingPairs()
                return
            }
            
            if previousSelection.cardSide == currentSelection.cardSide {
                self.previousSelection = nil
                
                selectPair(cardSide: cardSide, atRow: atRow)
                return
            }
            
            if isCorrect(previous: previousSelection, current: currentSelection) {
                previousSelection.state = .hidden
                currentSelection.state = .hidden
                
//                matchingPairs.remove(at: matchingPairs.index(where: { (pair: MatchingPair) -> Bool in
//                    return pair === previousSelection
//                })!)
//                
//                matchingPairs.remove(at: matchingPairs.index(where: { (pair: MatchingPair) -> Bool in
//                    return pair === currentSelection
//                })!)
            }
            self.previousSelection = nil
            
            delegate.reloadMatchingPairs()
        } else {
            //Other
            self.previousSelection = performSelect(cardSide: cardSide, atRow: atRow)
            delegate.reloadMatchingPairs()
        }
    }
    
    private func isCorrect(previous: MatchingPair, current: MatchingPair) -> Bool {
        return previous.wordPair == current.wordPair
    }
    
    private func performSelect(cardSide: CardSide, atRow: Int) -> MatchingPair? {
        let currentSelection = getPair(cardSide: cardSide, atRow: atRow)
        
        if(currentSelection.state == .hidden) {
            return nil
        }
        
        let numPairs = matchingPairs.count / 2
        let range = cardSide == .term ? 0..<numPairs : numPairs..<matchingPairs.count
        
        
        for i in range {
            let mwp = matchingPairs[i]
            
            if mwp.state == .hidden {
                continue
            }
            
            if mwp === currentSelection {
                mwp.state = .selected
            } else {
                mwp.state = .disabled
            }
        }
        return currentSelection
    }
    
    
    private func performDeselect(cardSide: CardSide, atRow: Int) -> MatchingPair {
        let currentSelection = getPair(cardSide: cardSide, atRow: atRow)
        for mwp in matchingPairs {
            if mwp.state != .hidden {
                mwp.state = .normal
            }
        }

        return currentSelection
    }
    
}

enum MatchingQuizState {
    case selected
    case disabled
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
