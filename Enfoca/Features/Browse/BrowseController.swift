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
}

class BrowseController : Controller {
    private let tag : Tag
    private let delegate: BrowseControllerDelegate
    let wordOrder: WordPairOrder
    
    var selectedWordPair: WordPair? 
    
    init(tag: Tag, wordOrder: WordPairOrder, delegate: BrowseControllerDelegate) {
        self.tag = tag
        self.delegate = delegate
        self.wordOrder = wordOrder
    }
    
    public func loadWordPairs(){
        services.fetchWordPairs(tagFilter: [tag], wordPairOrder: wordOrder, pattern: "") { (pairs: [WordPair]?, error:EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let pairs = pairs else {
                return
            }
            self.delegate.onBrowseResult(words: pairs)
        }
    }
    
    
    func title()-> String {
        return tag.name
    }
    
    func onEvent(event: Event) {
        
    }
}
