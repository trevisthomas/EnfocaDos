//
//  Tag+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

extension Tag {
    var uiColor: UIColor? {
        get {
            if let color = color {
                return UIColor(hexString: color)
            } else {
                return nil
            }
            
        }
    }
}
