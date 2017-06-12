//
//  HomeController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


protocol HomeControllerDelegate {
    func onError(title: String, message: EnfocaError)
    func onTagsLoaded(tags : [Tag])
    func onSearchResults(words: [WordPair])
    func onWordPairOrderChanged()
}

class HomeController: Controller {
    
    let delegate: HomeControllerDelegate!
    var selectedWordPair: WordPair?
    var selectedQuizTag: Tag?
    
    var wordOrder: WordPairOrder = .definitionAsc
    {
        didSet {
            if oldValue != wordOrder {
                self.search()
                delegate.onWordPairOrderChanged()
            }
        }
    }
    
    var phrase: String! {
        didSet {
            if oldValue != phrase {
                search()
            }
        }
    }
    
    init(delegate: HomeControllerDelegate) {
        self.delegate = delegate
    }
    
    func initialize(){
        loadDefaults()
    }
    
    func reloadTags() {
        services.fetchUserTags { (tags: [Tag]?, error: EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let tags = tags else {
                return
            }
            
            self.delegate.onTagsLoaded(tags: tags)
        }
    }
    
    private func loadDefaults(){
        self.wordOrder = appDefaults.wordPairOrder
    }
    
    func search(){
        
        services.fetchWordPairs(tagFilter: [], wordPairOrder: wordOrder, pattern: phrase) { (pairs: [WordPair]?, error:EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let pairs = pairs else {
                return
            }
            self.delegate.onSearchResults(words: pairs)
        }
    }
    
    func onEvent(event: Event) {
        switch(event.type) {
        case .tagCreated, .tagDeleted, .tagUpdate:
            reloadTags()
        case .wordPairCreated, .wordPairUpdated, .wordPairDeleted:
            search()
        }
    }
    
}
