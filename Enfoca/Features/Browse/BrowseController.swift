//
//  BrowseController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol BrowseControllerDelegate {
    func onBrowseResult(words: [WordPair])
    func onError(title: String, message: EnfocaError)
    func scrollToWordPair(wordPair: WordPair)
}

class BrowseController : Controller {
    private(set) var tag : Tag
    private let delegate: BrowseControllerDelegate
    let wordOrder: WordPairOrder
    
    var selectedWordPair: WordPair? 
    
    init(tag: Tag, wordOrder: WordPairOrder, delegate: BrowseControllerDelegate) {
        self.tag = tag
        self.delegate = delegate
        self.wordOrder = wordOrder
    }
    
    public func loadWordPairs(callback: @escaping ()->() = {}){
        services.fetchWordPairs(tagFilter: [tag], wordPairOrder: wordOrder, pattern: "") { (pairs: [WordPair]?, error:EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let pairs = pairs else {
                return
            }
            self.delegate.onBrowseResult(words: pairs)
            callback()
        }
    }
    
    
    func title()-> String {
        return tag.name
    }
    
    func onEvent(event: Event) {
        print("Browse controler recieved event \(event.type)")
        
        switch(event.type) {
        case .wordPairUpdated, .wordPairCreated, .wordPairDeleted:
            loadWordPairs(callback: { 
                //do it
                self.delegate.scrollToWordPair(wordPair: event.data as! WordPair)
            })
        case .tagUpdate:
            guard let updatedTag = event.data as? Tag else { fatalError() }
            if self.tag.tagId == updatedTag.tagId {
                self.tag = updatedTag
                loadWordPairs()
            }
        default: break
        }
    }
}
