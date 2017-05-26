//
//  CloudKitWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit
import CloudKit

//Deprecated?
class CloudKitWebService : WebService {
    func initialize(json: String?, progressObserver: ProgressObserver, callback: @escaping (Bool, EnfocaError?) -> ()) {
        
        db = CKContainer.default().publicCloudDatabase
        Perform.authentcate(db: db) { (userTuple : (Int, CKRecordID)?, error: String?) in
            guard let userTuple = userTuple else {
                callback(false, error)
                return
            }
            print("EnfocaId: \(userTuple.0)")
            self.enfocaId = NSNumber(value: userTuple.0)
            self.userRecordId = userTuple.1
            callback(true, nil)
        }
    }

    func serialize() -> String? {
        //
        return nil
    }

    private(set) var enfocaId : NSNumber!
    private(set) var db : CKDatabase!
    private(set) var userRecordId : CKRecordID!
    private var cursor : CKQueryCursor?
    
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
   
//    func initialize(callback: @escaping (Bool, EnfocaError?) -> ()) {
//        db = CKContainer.default().publicCloudDatabase
//        Perform.authentcate(db: db) { (userTuple : (Int, CKRecordID)?, error: String?) in
//            guard let userTuple = userTuple else {
//                callback(false, error)
//                return
//            }
//            print("EnfocaId: \(userTuple.0)")
//            self.enfocaId = NSNumber(value: userTuple.0)
//            self.userRecordId = userTuple.1
//            callback(true, nil)
//        }
//    }
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()) {
        guard enfocaId == enfocaId else {
            callback(nil, "Cloudkit webservice not initialized")
            return 
        }
        
//        Perform.fetchTags(enfocaId: enfocaId, db: db) { (tags:[Tag]?, error: String?) in
//            guard let tags = tags else {
//                callback(nil, error)
//                return
//            }
//            callback(tags, nil)
//        }
    }
    
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair]?,EnfocaError?)->()) {
        
        cursor = nil
        
        Perform.fetchWordPairs(tags: tagFilter, wordPairOrder: wordPairOrder, phrase: pattern, enfocaId: enfocaId, db: db, callback: { (wordPairs:[WordPair]?, error:EnfocaError?) in
            callback(wordPairs, error)
        }) { (cursor:CKQueryCursor) in
            self.cursor = cursor
        }
        
    }
    
    func fetchNextWordPairs(callback : @escaping([WordPair]?,EnfocaError?)->()) {
        guard let cursor = cursor else {
            callback(nil, "Cursor is not available.")
            return
        }
        Perform.fetchNextWordPairs(cursor : cursor, db: db, callback: { (wordPairs:[WordPair]?, error:EnfocaError?) in
            callback(wordPairs, error)
        }) { (cursor:CKQueryCursor) in
            self.cursor = cursor
        }
    }
    
    func wordPairCount(tagFilter: [Tag], pattern : String?, callback : @escaping(Int?, EnfocaError?)->()){
        Perform.countWordPairs(withTags: tagFilter, phrase: pattern, enfocaId: enfocaId, db: db) { (count:Int?, error:String?) in
            callback(count, error)
        }
        
        //Demo!
//        Perform.createDataStore(enfocaId: enfocaId, db: db) { (dataStore: DataStore?, error:EnfocaError?) in
//            
//            guard let _ = dataStore else {
//                guard let error = error else { fatalError() }
//                print("Error creating data store \(error)")
//                return
//            }
//            print("Demo created data store")
//        }
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->()){
        
        let wordPair = WordPair(pairId: "", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: [], example: example)
        
        Perform.createWordPair(wordPair: wordPair, enfocaId: enfocaId, db: db) { (wordPair:WordPair?, error:String?) in
            callback(wordPair, error)
        }
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()){
        
        //TODO: Code it up!
        
    }
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->()) {
        Perform.createTag(tagName: tagValue, enfocaId: enfocaId, db: db) { (tag:Tag?, error: String?) in
            callback(tag, error)
        }
    }
    
    func updateTag(oldTag: Tag, newTagName: String, callback: @escaping (Tag?, EnfocaError?) -> ()) {
        
    }
 
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()) {}
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){}
}
