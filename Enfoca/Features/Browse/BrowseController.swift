//
//  BrowseController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol BrowseControllerDelegate {
    
}

class BrowseController : Controller {
    private let tag : Tag
    private let delegate: BrowseControllerDelegate
    
    init(tag: Tag, delegate: BrowseControllerDelegate) {
        self.tag = tag
        self.delegate = delegate
    }
    
    func title()-> String {
        return tag.name
    }
    
    func onEvent(event: Event) {
        
    }
}
