//
//  CardViewControllerDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol CardViewControllerDelegate {
    func getRearWord() -> String
    func getFrontWord() -> String
    
    func correct()
    func incorrect()
    
    func getWordPairsForMatching() -> [WordPair]
    
    func onError(title: String, message: EnfocaError)
}
