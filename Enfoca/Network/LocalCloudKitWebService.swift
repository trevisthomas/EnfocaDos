//
//  LocalCloudKitWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit
import CloudKit


class LocalCloudKitWebService : WebService {
    
    private(set) var enfocaId : NSNumber!
    private(set) var db : CKDatabase!
    private(set) var privateDb : CKDatabase!
    private(set) var userRecordId : CKRecordID!
    private var dataStore: DataStore!
    
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
    func initialize(json: String?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        db = CKContainer.default().publicCloudDatabase
        privateDb = CKContainer.default().privateCloudDatabase
        
        Perform.authentcate(db: db) { (userTuple : (Int, CKRecordID)?, error: String?) in
            guard let userTuple = userTuple else {
                callback(false, error)
                return
            }
            print("EnfocaId: \(userTuple.0)")
            self.enfocaId = NSNumber(value: userTuple.0)
            self.userRecordId = userTuple.1
            
            let ds = DataStore()
            
            if let json = json {
                ds.initialize(json: json)
            }
            
            if ds.isInitialized {
                self.dataStore = ds
                callback(true, nil)
                return
            } else {
                Perform.initializeDataStore(dataStore: ds, enfocaId: self.enfocaId, db: self.db, privateDb: self.privateDb, progressObserver: progressObserver) { (ds : DataStore?, error: EnfocaError?) in
                    if let error = error {
                        callback(false, error)
                    }
                    guard let dataStore = ds else {
                        callback(false, "DataStore was nil.  This is a fatal error.")
                        return;
                    }
                    self.dataStore = dataStore
                    
                    callback(true, nil)
                }
            }
        }
    }
    
    func serialize() -> String? {
        return dataStore.toJson()
    }
    
//    func initialize(callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
//        //Deprecated?
//        fatalError()
//    }
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()) {
        callback(dataStore.allTags(), nil)
    }
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair]?,EnfocaError?)->()){
        
        let sorted = dataStore.search(wordPairMatching: pattern ?? "", order: wordPairOrder, withTags: tagFilter)
        callback(sorted, nil)
        
    }
    
    func fetchNextWordPairs(callback : @escaping([WordPair]?,EnfocaError?)->()){
        //Deprecated.
    }
    
    func wordPairCount(tagFilter: [Tag], pattern : String?, callback : @escaping(Int?, EnfocaError?)->()) {
        //Deprecated
        callback(dataStore.wordPairDictionary.count, nil)
        //Git rid of this method after fixing model.
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->()){
        
        let newWordPair = WordPair(pairId: "", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        
        Perform.createWordPair(wordPair: newWordPair, enfocaId: enfocaId, db: db) { (wordPair:WordPair?, error:String?) in
            
            if let error = error {
                callback(nil, error)
            }
            
            guard let wordPair = wordPair else { return }
            
            self.dataStore.add(wordPair: wordPair)
            
            //Create any tag associations for this new word.
            for tag in tags {
                Perform.createTagAssociation(tagId: tag.tagId, wordPairId: wordPair.pairId, enfocaId: self.enfocaId, db: self.db, callback: { (tagAss:TagAssociation?, error:String?) in
                    
                    if let error = error {
                        callback(nil, error)
                    }

                    guard let association = tagAss else { return }
                    
                    self.dataStore.add(tagAssociation: association)
                })
            }
            
            
            
            callback(wordPair, error)
        }
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()){
        
        let tuple = dataStore.applyUpdate(oldWordPair: oldWordPair, word: word, definition: definition, gender: gender, example: example, tags: tags)
        
        //The numer of oprations that will be executed
        var opsRemaining = 1 + tuple.1.count + tuple.2.count
        
        func notifyOnOpsCompleted(){
            //A psudo latch
            opsRemaining -= 1
            if opsRemaining == 0 {
                callback(tuple.0, nil)
            }
        }
        
        Perform.updateWordPair(wordPair: tuple.0, enfocaId: enfocaId, db: db) { (wp:WordPair?, error:String?) in
            
            if let error = error {
                callback(nil, error)
            }
            notifyOnOpsCompleted()
        }
        
        for tag in tuple.1 {
            Perform.createTagAssociation(tagId: tag.tagId, wordPairId: oldWordPair.pairId, enfocaId: self.enfocaId, db: self.db, callback: { (tagAss:TagAssociation?, error:String?) in
                
                if let error = error { callback(nil, error) }
                
                guard let assocation = tagAss else { fatalError() }
                self.dataStore.add(tagAssociation: assocation)
                notifyOnOpsCompleted()
            })
        }
        
        for tagAss in tuple.2 {
            Perform.deleteTagAssociation(tagAssociation: tagAss, enfocaId: self.enfocaId, db: self.db, callback: { (recordId: String?, error: String?) in
                if let error = error { callback(nil, error) }
                notifyOnOpsCompleted()
            })
        }
        
        
        
    }
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->()){
        
        Perform.createTag(tagName: tagValue, enfocaId: enfocaId, db: db) { (tag:Tag?, error: String?) in
            
            if let error = error {
                callback(nil, error)
            }
            
            guard let tag = tag else { fatalError() }
            
            self.dataStore.add(tag: tag)
            callback(tag, nil)
        }
        
        
    }
    
    func updateTag(oldTag : Tag, newTagName: String, callback: @escaping(Tag?, EnfocaError?)->()) {
        
        let newTag = dataStore.applyUpdate(oldTag: oldTag, name: newTagName)
        
        Perform.updateTag(updatedTag: newTag, enfocaId: enfocaId, db: db) { (tag:Tag?, error:String?) in
            
            if let error = error { callback(nil, error) }
            
            guard let tag = tag else { fatalError() }
            
            callback(tag, nil)
        }
    }
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()) {
        
        showNetworkActivityIndicator = true
        let associations = dataStore.remove(wordPair: wordPair)
        
        //The numer of oprations that will be executed
        var opsRemaining = 1 + associations.count
        
        func notifyOnOpsCompleted(){
            //A psudo latch
            opsRemaining -= 1
            if opsRemaining == 0 {
                callback(wordPair, nil)
                showNetworkActivityIndicator = false
            }
        }
        
        Perform.deleteWordPair(wordPair: wordPair, enfocaId: enfocaId, db: db) { (recordId: String?, error: String?) in
            
            if let error = error {
                callback(nil, error)
                self.showNetworkActivityIndicator = false
            }
            notifyOnOpsCompleted()
            
        }
        
        for associaion in associations {
            Perform.deleteTagAssociation(tagAssociation: associaion, enfocaId: enfocaId, db: db) { (recordId:String?, error:String?) in
                if let error = error {
                    callback(nil, error)
                    self.showNetworkActivityIndicator = false
                }
                notifyOnOpsCompleted()
            }
        }
    }
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){
        showNetworkActivityIndicator = true
        let associations = dataStore.remove(tag: tag)
        
        //The numer of oprations that will be executed
        var opsRemaining = 1 + associations.count
        
        func notifyOnOpsCompleted(){
            //A psudo latch
            opsRemaining -= 1
            if opsRemaining == 0 {
                callback(tag, nil)
                showNetworkActivityIndicator = false
            }
        }
        
        Perform.deleteTag(tag: tag, enfocaId: enfocaId, db: db) { (recordId: String?, error: String?) in
            
            if let error = error {
                callback(nil, error)
                self.showNetworkActivityIndicator = false
            }
            notifyOnOpsCompleted()
            
        }
        
        for associaion in associations {
            Perform.deleteTagAssociation(tagAssociation: associaion, enfocaId: enfocaId, db: db) { (recordId:String?, error:String?) in
                if let error = error {
                    callback(nil, error)
                    self.showNetworkActivityIndicator = false
                }
                notifyOnOpsCompleted()
            }
        }
    }
}
