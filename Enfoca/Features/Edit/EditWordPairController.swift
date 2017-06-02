//
//  WordPairEditorController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EditWordPairControllerDelegate {
    func onTagsLoaded(tags: [Tag], selectedTags: [Tag])
    func onError(title: String, message: EnfocaError)
    func onUpdate()
}

class EditWordPairController: Controller {
    //TODO: Shouln't these be weak?
    private let delegate: EditWordPairControllerDelegate
//    public let wordPair: WordPair?
    
    var selectedTags: [Tag] = [] {
        didSet{
            delegate.onUpdate()
        }
    }
    var word: String = ""
    var definition: String = ""
    let isEditMode: Bool
    
    init(delegate: EditWordPairControllerDelegate, wordPair: WordPair?) {
        self.delegate = delegate
        
        if let wordPair = wordPair {
            isEditMode = true
            selectedTags.append(contentsOf: wordPair.tags)
            word = wordPair.word
            definition = wordPair.definition
        } else {
            isEditMode = false
        }
    }
    
    func initialize(){
        
        services.fetchUserTags { (tags: [Tag]?, error: EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let tags = tags else {
                return
            }
            
            self.delegate.onTagsLoaded(tags: tags, selectedTags: self.selectedTags)
        }
    }
    
    func title()->String{
        if isEditMode {
            return "Edit"
        } else {
            return "Create"
        }
    }
    
    func addTag(tag: Tag) {
        selectedTags.append(tag)
        selectedTags.sort { (t1:Tag, t2:Tag) -> Bool in
            return t1.name.lowercased() < t2.name.lowercased()
        }
        delegate.onUpdate()
    }
    
    
    
    func removeTag(tag: Tag) {
        if let index = selectedTags.index(of: tag) {
            selectedTags.remove(at: index)
        }
        delegate.onUpdate()
    }
    
    func tagsAsString() -> String {
        return selectedTags.tagsToText()
    }
    
    func onEvent(event: Event) {
        //TOOD
    }

}

