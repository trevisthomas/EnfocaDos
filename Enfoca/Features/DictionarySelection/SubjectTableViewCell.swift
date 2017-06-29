//
//  SubjectTableViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol SubjectTableViewCellDelegate {
    func performSelect(dictionary: UserDictionary)
}

class SubjectTableViewCell: UITableViewCell {
    private var delegate: SubjectTableViewCellDelegate!
    
    static let identifier = "SubjectTableViewCell"

    @IBOutlet weak var myButton: EnfocaButton!
    private var dictionary: UserDictionary!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialize(delegate: SubjectTableViewCellDelegate, dictionary: UserDictionary){
        self.dictionary = dictionary
        self.delegate = delegate
        
        myButton.setTitle(dictionary.subject, for: .normal)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        delegate.performSelect(dictionary: dictionary)
    }
    

}
