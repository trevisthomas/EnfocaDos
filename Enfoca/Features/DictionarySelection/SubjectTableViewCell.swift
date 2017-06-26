//
//  SubjectTableViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class SubjectTableViewCell: UITableViewCell {
    
    static let identifier = "SubjectTableViewCell"

    @IBOutlet weak var myButton: EnfocaButton!
    private var dictionary: Dictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialize(dictionary: Dictionary){
        self.dictionary = dictionary
        
        myButton.setTitle(dictionary.subject, for: .normal)
    }
    
    

}
