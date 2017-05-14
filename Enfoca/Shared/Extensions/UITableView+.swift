//
//  UITableView+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/8/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

extension UITableView {
    
    //http://stackoverflow.com/questions/16071503/how-to-tell-when-uitableview-has-completed-reloaddata
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0.0, animations: {
            self.reloadData()
        }, completion: {_ in
            completion()
        })
    }
}
