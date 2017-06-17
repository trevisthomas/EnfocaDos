//
//  CardViewControllerDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

//protocol CardViewControllerDelegate {
//    func onError(title: String, message: EnfocaError)
//}


protocol QuizViewModel {
    func getRearWord() -> String
    func getFrontWord() -> String
    
    func correct()
    func incorrect()
    
    func getWordPairsForMatchingRound() -> [WordPair]
    
    func isTimeForMatchingRound() -> Bool
    func isFinished() -> Bool
}
