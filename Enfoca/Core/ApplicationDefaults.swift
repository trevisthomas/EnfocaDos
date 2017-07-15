//
//  ApplicationDefaults.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/31/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol ApplicationDefaults {
    var reverseWordPair : Bool {get set}
    var selectedTags : [Tag] {get set}
    var fetchWordPairPageSize : Int {get}
    func save(dictionary: UserDictionary, includingDataStore data: Data?)
    func load() -> Data?
    func loadDataStore(forDictionaryId dictionaryId: String) -> Data?
    
    func clearUserDefauts()
    func removeDictionary(_ dictionary: UserDictionary)
    
    var cardOrder: CardOrder {get set}
    var cardSide: CardSide {get set}
    var quizWordCount: Int {get set}
    var numberOfIncorrectAnswersTillReview: Int {get set}
    
    var wordPairOrder: WordPairOrder {get set}
    var cardTimeout: Int {get set}
    var cardTimeoutWarning: Int {get set}
    
    func insertMostRecentTag(tag: Tag)
    func removeFromMostRecentTag(tag: Tag)
    func getMostRecentlyUsedTags() -> [Tag]
    
    var noneTag: Tag {get}
    var anyTag: Tag {get}
}

class LocalApplicationDefaults : ApplicationDefaults {
    
    let dataStoreKey : String = "ActiveDictionaryKey"
    var selectedTags : [Tag] = []
    var reverseWordPair : Bool = false
    var cardOrder: CardOrder = .latestAdded
    var cardSide: CardSide = .definition
    var quizWordCount: Int = 10
    var wordPairOrder: WordPairOrder = .wordAsc
    var numberOfIncorrectAnswersTillReview: Int = 5
    var cardTimeout: Int = 30
    var cardTimeoutWarning: Int = 5
    var mostRecentlyUsedTags: [Tag] = []
    let noneTag: Tag = Tag(tagId: "noneTag", name: "None")
    let anyTag: Tag = Tag(tagId: "anyTag", name: "Any")
    
    var fetchWordPairPageSize: Int {
        get {
            return 100
        }
    }
    
    func insertMostRecentTag(tag: Tag) {
        
        if tag == noneTag || tag == anyTag {
            return
        }
        
        if let remove = mostRecentlyUsedTags.index(of: tag) {
            mostRecentlyUsedTags.remove(at: remove)
        }
        mostRecentlyUsedTags.insert(tag, at: 0)
    }
    
    func removeFromMostRecentTag(tag: Tag) {
        if let remove = mostRecentlyUsedTags.index(of: tag) {
            mostRecentlyUsedTags.remove(at: remove)
        }
    }
    
    func getMostRecentlyUsedTags() -> [Tag] {
        return mostRecentlyUsedTags
    }
    
    func save(dictionary: UserDictionary, includingDataStore data: Data?) {
        if isTestMode() {
            print("Not saving user defaults.  We're in test mode")
            return
        }
        
        print("Saving user data")
        
        let defaults = UserDefaults.standard
        
        if let data = data {
            defaults.setValue(data, forKey: dictionary.dictionaryId)
            defaults.setValue(dictionary.dictionaryId, forKey: dataStoreKey)
        }
    }
    
    //Does not delete cached dictionaries, just which one was active
    func clearUserDefauts() {
        mostRecentlyUsedTags = []
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: dataStoreKey)
    }
    
    //This is how you remove a cached dictionary
    func removeDictionary(_ dictionary: UserDictionary) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: dataStoreKey)
        defaults.removeObject(forKey: dictionary.dictionaryId)
    }
    
    func load() -> Data? {
        
        if isTestMode() {
            print("Not loading user defaults.  We're in test mode")
            return nil
        }
        
        
        var data: Data? = nil
        let defaults = UserDefaults.standard
        if let dictionaryId = defaults.value(forKey: dataStoreKey) as? String {
            data = loadDataStore(forDictionaryId: dictionaryId)
        }
        
        
        //Load other default settings
        
        return data
    }
    
    func loadDataStore(forDictionaryId dictionaryId: String) -> Data? {
        
        if isTestMode() {
            print("Not loading user defaults.  We're in test mode")
            return nil
        }
        
        let defaults = UserDefaults.standard
        let data = defaults.value(forKey: dictionaryId) as? Data
        
        return data
    }
    
    func deleteDataStoreFromCache(forDictionaryId dictionaryId: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: dictionaryId)
        
    }
    
}
