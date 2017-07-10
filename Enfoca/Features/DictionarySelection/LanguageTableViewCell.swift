//
//  LanguageTableViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {
    @IBOutlet weak var languageNameLabel: UILabel!
    @IBOutlet weak var languageCodeLabel: UILabel!
    
    private var language: Language!
    
    static let identifier: String = "LanguageTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initialize(language: Language) {
        self.language = language
        
        languageNameLabel.text = language.name
        languageCodeLabel.text = language.code
    }
}
