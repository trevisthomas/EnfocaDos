//
//  TagFilterViewModelDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/12/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol TagFilterViewModelDelegate {
    func selectedTagsChanged()
    func reloadTable()
    func alert(title : String, message : String)
    func presentColorSelector(colorSelectorDelegate: ColorSelectorViewControllerDelegate, source: UIView)
}
