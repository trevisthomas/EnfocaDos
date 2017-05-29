//
//  WordPairEditorController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EditWordPairControllerDelegate {
    
}

class EditWordPairController: Controller {
    //TODO: Shouln't these be weak?
    private let delegate: EditWordPairControllerDelegate
    public let wordPair: WordPair?
    
    
    init(delegate: EditWordPairControllerDelegate, wordPair: WordPair?) {
        self.delegate = delegate
        self.wordPair = wordPair
    }
    
    func isEditMode() -> Bool {
        if let _ = wordPair {
            return true
        }
        return false
    }
    
    func title()->String{
        if isEditMode() {
            return "Edit"
        } else {
            return "Create"
        }
    }
    
    func onEvent(event: Event) {
        //TOOD
    }

}

