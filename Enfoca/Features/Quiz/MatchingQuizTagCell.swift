//
//  MatchingQuizTagCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/13/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


enum MatchingQuizState {
    case term
    case definition
    case selected
    case hidden
}

class MatchingQuizTagCell: UICollectionViewCell {
    static let identifier: String = "MatchingQuizTagCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    
    
    func applyColors(text: UIColor, background: UIColor) {
        self.backgroundColor = background
        self.titleLabel.textColor = text
    }
}
