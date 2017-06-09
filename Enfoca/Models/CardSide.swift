//
//  CardSide.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

enum CardSide : String {
    case term = "Term"
    case definition = "Definition"
    case random = "Random"
    
    static let values = [definition, random, term]
}
