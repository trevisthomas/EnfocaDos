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
    
//    private(set) var dictionary: UserDictionary!
//    private(set) var enfocaId : NSNumber!
    
    var enfocaId: NSNumber {
        get{
            return dataStore.getEnfocaId()
        }
    }
    
    private(set) var db : CKDatabase!
    private(set) var privateDb : CKDatabase!
    private(set) var userRecordId : CKRecordID!  //Not really using this here.
    private var dataStore: DataStore!
    
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
    //This needs to be called first to initialize the things.  
    //It will eventually replace the old init method.
    //TODO: Rename to pre-initialize?
    func initialize(callback : @escaping([UserDictionary]?, EnfocaError?)->()){
        
        showNetworkActivityIndicator = true
        
        db = CKContainer.default().publicCloudDatabase
        privateDb = CKContainer.default().privateCloudDatabase
        
        Perform.initialize(db: db) { (tuple:(CKRecordID, [UserDictionary])?, error: String?) in
            self.showNetworkActivityIndicator = false
            if let error = error {
                callback(nil, error)
            }
            
            guard let tuple = tuple else {
                callback([], nil)
                return
            }
            
            
            self.userRecordId = tuple.0
          
            callback(tuple.1, nil)
        }
    }
    
    func createDictionary(termTitle: String, definitionTitle: String, subject: String, language: String? = nil, callback : @escaping(UserDictionary?, EnfocaError?)->()) {
        showNetworkActivityIndicator = true
        
        let dictionary = UserDictionary(dictionaryId: "not-set", userRef: userRecordId.recordName, enfocaId: -1, termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
        //Remember, this method generates an enfoca id.
        Perform.createDictionary(db: db, dictionary: dictionary) { (dictionary: UserDictionary?, error: String?) in
            
            if let error = error { callback(nil, error) }
            
            guard let dictionary = dictionary else { fatalError("Unhandled error") }
            
            callback(dictionary, nil)
        }
        
    }
    
    func prepareDataStore(dictionary: UserDictionary?, json: String?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        let ds: DataStore
        
        if let json = json {
            ds = DataStore(json: json)
        } else if let dictionary = dictionary {
            ds = DataStore(dictionary: dictionary)
        } else {
            fatalError() //I need one or the other.
        }
        
        
//        self.enfocaId = dictionary.enfocaId
//        self.dictionary = dictionary
        
//        let ds = DataStore(dictionary: dictionary)
        
//        if let json = json {
//            ds.initialize(json: json)
//        }
        
        if ds.isInitialized {
            self.dataStore = ds
            
            invokeLater {
                callback(true, nil)
            }
            
            return
        } else {
            Perform.initializeDataStore(dataStore: ds, enfocaId: ds.getEnfocaId(), db: self.db, privateDb: self.privateDb, progressObserver: progressObserver) { (ds : DataStore?, error: EnfocaError?) in
                invokeLater {
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
        fatalError()
        
//        callback(dataStore.wordPairDictionary.count, nil)
        
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
        showNetworkActivityIndicator = true
        let newTag = dataStore.applyUpdate(oldTag: oldTag, name: newTagName)
        
        Perform.updateTag(updatedTag: newTag, enfocaId: enfocaId, db: db) { (tag:Tag?, error:String?) in
            self.showNetworkActivityIndicator = false
            
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
    
    func fetchQuiz(forTag: Tag?, cardOrder: CardOrder, wordCount: Int, callback: @escaping([WordPair]?, EnfocaError?)->()) {
        
        var wordPairs : [WordPair]!
        if let tag = forTag {
            wordPairs = dataStore.fetchQuiz(cardOrder: cardOrder, wordCount: wordCount, forTags: [tag])
        } else {
            wordPairs = dataStore.fetchQuiz(cardOrder: cardOrder, wordCount: wordCount)
        }
        
        callback(wordPairs, nil)
    }
    
    func updateScore(forWordPair: WordPair, correct: Bool, elapsedTime: Int, callback: @escaping(MetaData?, EnfocaError?)->()) {
        
        showNetworkActivityIndicator = true
        
        let metaData = dataStore.getMetaData(forWordPair: forWordPair)
        
        if let currentMetaData = metaData {
            //Update
            self.dataStore.updateScore(metaData: currentMetaData, correct: correct, elapsedTime: elapsedTime)
            
            Perform.updateMetaData(updatedMetaData: currentMetaData, enfocaId: enfocaId, db: privateDb) { (metaData: MetaData?, error: String?) in
                self.showNetworkActivityIndicator = false
                
                if let error = error { callback(nil, error) }
                guard let metaData = metaData else { fatalError() }
                callback(metaData, nil)
            }
        } else {
            //Create
            let newMetaData = MetaData(metaId: "notset", pairId: forWordPair.pairId, dateCreated: Date(), dateUpdated: Date(), incorrectCount: 0, totalTime: 0, timedViewCount: 0)
            
            dataStore.updateScore(metaData: newMetaData, correct: correct, elapsedTime: elapsedTime)
            
            Perform.createMetaData(metaDataSource: newMetaData, enfocaId: enfocaId, db: privateDb, callback: { (metaData: MetaData?, error: String?) in
                self.showNetworkActivityIndicator = false
                if let error = error { callback(nil, error) }
                guard let metaData = metaData else { fatalError() }
                
//                forWordPair.metaData = metaData
                self.dataStore.add(metaData: metaData)
                callback(metaData, nil)
            })
        }
        
    }
    
    func fetchMetaData(forWordPair wordPair: WordPair, callback: @escaping(MetaData?, EnfocaError?)->()) {
        guard let meta = dataStore.getMetaData(forWordPair: wordPair) else {
            //This isn't really an error. Not all words have meta.
            callback(nil, "Meta Data not found for word pair \(wordPair.pairId)")
            return
        }
        callback(meta, nil)
    }
    
    
    
}
