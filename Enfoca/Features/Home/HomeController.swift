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
            guard var tags = tags else {
                return
            }
            
            tags.insert(self.appDefaults.anyTag, at: 0)
            tags.insert(self.appDefaults.noneTag, at: 1)
            
            self.delegate.onTagsLoaded(tags: tags)
        }
    }
    
    private func loadDefaults(){
        self.wordOrder = appDefaults.wordPairOrder
    }
    
    func search(){
        let phrase : String = self.phrase ?? ""
        let regex = "\\b\(phrase)"
        services.fetchWordPairs(tagFilter: [], wordPairOrder: wordOrder, pattern: regex) { (pairs: [WordPair]?, error:EnfocaError?) in
            if let error = error {
                self.delegate.onError(title: "Error fetching tags", message: error)
            }
            guard let pairs = pairs else {
                return
            }
            self.delegate.onSearchResults(words: pairs)
        }
    }
    
    func isDataStoreSynchronized(callback: @escaping (Bool)->()) {
        
        services.isDataStoreSynchronized { (inSynch: Bool?, error: String?) in
            guard let inSynch = inSynch else {
                //retry
                delay(delayInSeconds: 5, callback: { 
                    self.isDataStoreSynchronized(callback: callback)
                })
                return
            }
            
            callback(inSynch)
            
        }
        
    }
    
    func getCurrentDictionary() -> UserDictionary {
        return services.getCurrentDictionary()
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
