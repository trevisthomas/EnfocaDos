//
//  UITextField+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

extension UITextField {
    
    func setPlaceholderTextColor(color: UIColor) {
        let placeHolderText = self.placeholder!
        self.attributedPlaceholder = NSAttributedString(string: placeHolderText,
                                                                           attributes: [NSForegroundColorAttributeName: color])
    }
}
