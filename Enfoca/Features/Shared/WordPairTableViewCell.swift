//
//  WordPairTableViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class WordPairTableViewCell: UITableViewCell {
    fileprivate var wordPair : WordPair!
    public static let identifier : String = "WordPairTableViewCellId"

    @IBOutlet weak var primarTextLabel: UILabel!
    @IBOutlet weak var secondaryTextLabel: UILabel!
    @IBOutlet weak var tagsTextLabel: UILabel!
    @IBOutlet weak var scoreTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension WordPairTableViewCell {
    func initialize(wordPair: WordPair, order: WordPairOrder){
        self.wordPair = wordPair
        
        switch order{
        case .definitionAsc, .definitionDesc:
            self.primarTextLabel.text = wordPair.definition
            self.secondaryTextLabel.text = wordPair.word
        case .wordAsc, . wordDesc:
            self.primarTextLabel.text = wordPair.word
            self.secondaryTextLabel.text = wordPair.definition
        }
        
        self.tagsTextLabel.text = wordPair.tags.tagsToText()
        
        self.scoreTextLabel.text = wordPair.metaData?.scoreAsString
        
    }
}
