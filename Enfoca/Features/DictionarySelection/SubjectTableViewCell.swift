//
//  SubjectTableViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol SubjectTableViewCellDelegate {
    func performSelect(dictionary: Dictionary)
}

class SubjectTableViewCell: UITableViewCell {
    private var delegate: SubjectTableViewCellDelegate!
    
    static let identifier = "SubjectTableViewCell"

    @IBOutlet weak var myButton: EnfocaButton!
    private var dictionary: Dictionary!
//    fileprivate var selectionMode: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initialize(delegate: SubjectTableViewCellDelegate, dictionary: Dictionary){
        self.dictionary = dictionary
        self.delegate = delegate
//        self.selectionMode = selectMode
        
        myButton.setTitle(dictionary.subject, for: .normal)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        delegate.performSelect(dictionary: dictionary)

//        if selectionMode {
//            delegate.performSelect(dictionary: dictionary)
//        } else {
//            delegate.performCreateOrUpdate(dictionary: dictionary)
//        }
    }
    

}
