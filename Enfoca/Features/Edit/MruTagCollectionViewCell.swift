//
//  MruTagCollectionViewCell.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class MruTagCollectionViewCell: UICollectionViewCell {
    static let identifier = "MruTagCollectionViewCell"
    
    @IBOutlet weak var label: UILabel!
    
    private var enfocaTag: Tag!
    
    func initialize(tag: Tag) {
        self.enfocaTag = tag
        label.text = tag.name
    }
    
}
