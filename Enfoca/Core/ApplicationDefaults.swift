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
    func save(dictionary: UserDictionary, includingDataStore json: String?)
    func load() -> String?
    func loadDataStore(forDictionaryId dictionaryId: String) -> String? 
    func clearUserDefauts()
    func removeDictionary(_ dictionary: UserDictionary)
    
    var cardOrder: CardOrder {get set}
    var cardSide: CardSide {get set}
    var quizWordCount: Int {get set}
    var numberOfIncorrectAnswersTillReview: Int {get set}
    
    var wordPairOrder: WordPairOrder {get set}
    var cardTimeout: Int {get set}
    var cardTimeoutWarning: Int {get set}
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
    
    var fetchWordPairPageSize: Int {
        get {
            return 100
        }
    }
    
    func save(dictionary: UserDictionary, includingDataStore json: String?){
        if isTestMode() {
            print("Not saving user defaults.  We're in test mode")
            return
        }
        
        print("Saving user data")
        
        let defaults = UserDefaults.standard
        
        if let json = json {
            defaults.setValue(json, forKey: dictionary.dictionaryId)
            defaults.setValue(dictionary.dictionaryId, forKey: dataStoreKey)
        }
    }
    
    //Does not delete cached dictionaries, just which one was active
    func clearUserDefauts() {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: dataStoreKey)
    }
    
    //This is how you remove a cached dictionary
    func removeDictionary(_ dictionary: UserDictionary) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: dataStoreKey)
        defaults.removeObject(forKey: dictionary.dictionaryId)
    }
    
    func load() -> String? {
        
        if isTestMode() {
            print("Not loading user defaults.  We're in test mode")
            return nil
        }
        
        
        var json: String? = nil
        let defaults = UserDefaults.standard
        if let dictionaryId = defaults.value(forKey: dataStoreKey) as? String {
            json = loadDataStore(forDictionaryId: dictionaryId)
        }
        
        //In case of a dirty shut down, i dont want the old data lying around
        //This doesnt work when you kill the app on a real device.
//        defaults.removeObject(forKey: dataStoreKey)

        
        //Load other default settings
        
        return json
    }
    
    func loadDataStore(forDictionaryId dictionaryId: String) -> String? {
        
        if isTestMode() {
            print("Not loading user defaults.  We're in test mode")
            return nil
        }
        
        let defaults = UserDefaults.standard
        let json = defaults.value(forKey: dictionaryId) as? String
        defaults.removeObject(forKey: dictionaryId) //Delete the local cache, it is resaved after successful parse
        return json
    }
    
}
