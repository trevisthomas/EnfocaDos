//
//  TagCollectionViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class TagCollectionViewCell : UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    static let identifier: String = "TagCollectionViewCellId"
    
    var t: Tag!
    func seed(tag: Tag) {
        t = tag
        
        titleLabel.text = t.name
    }
    
}
