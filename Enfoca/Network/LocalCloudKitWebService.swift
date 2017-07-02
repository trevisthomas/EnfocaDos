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

    private var enfocaRef: CKReference!
    
    private var subscriptionForWordPair: CKSubscription?
    private(set) var db : CKDatabase!
    private(set) var privateDb : CKDatabase!
    private(set) var userRecordId : CKRecordID!  //Not really using this here.
    private var dataStore: DataStore! {
        didSet{
            let recordId = CloudKitConverters.toCKRecordID(fromRecordName: dataStore.getUserDictionary().enfocaRef)
            enfocaRef = CKReference(recordID: recordId, action: .none)
        }
    }
    
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
        
        let dictionary = UserDictionary(dictionaryId: "not-set", userRef: userRecordId.recordName, enfocaRef: "not-set-generated-by-this-method", termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
        //Remember, this method generates an enfoca id. Well it used to.  I guess it's a ref now
        Perform.createDictionary(db: db, dictionary: dictionary) { (dictionary: UserDictionary?, error: String?) in
            
            if let error = error { callback(nil, error) }
            
            guard let dictionary = dictionary else { fatalError("Unhandled error") }
            
            callback(dictionary, nil)
        }
        
    }
    
    func prepareDataStore(dictionary: UserDictionary?, json: String?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        showNetworkActivityIndicator = true
        
        let ds: DataStore
        
        if let json = json {
            ds = DataStore(json: json)
        } else if let dictionary = dictionary {
            ds = DataStore(dictionary: dictionary)
        } else {
            fatalError() //I need one or the other.
        }
        
        if ds.isInitialized {
            self.dataStore = ds
            ConchLocalStorage.save(ds.getUserDictionary().conch)
            
            invokeLater {
                //                self.initializeCloudKitSubscriptions(callback: callback)
                self.showNetworkActivityIndicator = false
                callback(true, nil)
            }
            
            return
        } else {
            
            let recordId = CloudKitConverters.toCKRecordID(fromRecordName: ds.getUserDictionary().enfocaRef)
            let tempRef = CKReference(recordID: recordId, action: .none)
            
            
            Perform.loadOrCreateConch(enfocaRef: tempRef, db: self.db, callback: { (tuple:(String, Bool)?, error: EnfocaError?) in
                if let error = error {
                    callback(false, error)
                    return
                }
                
                guard let tuple = tuple else { fatalError() }
                
                let conch = tuple.0
                //Turns out that i dont care if it's new.  I'm doing a fresh load, that means i'm in synch.
//                let isNew = tuple.1
                
                ds.getUserDictionary().conch = conch
                
                ConchLocalStorage.save(conch)
                
                Perform.initializeDataStore(dataStore: ds, enfocaRef: tempRef, db: self.db, privateDb: self.privateDb, progressObserver: progressObserver) { (ds : DataStore?, error: EnfocaError?) in
                    invokeLater {
                        if let error = error {
                            callback(false, error)
                        }
                        guard let dataStore = ds else {
                            callback(false, "DataStore was nil.  This is a fatal error.")
                            return;
                        }
                        self.dataStore = dataStore
                        
                        //                    self.initializeCloudKitSubscriptions(callback: callback)
                        self.showNetworkActivityIndicator = false
                        callback(true, nil)
                    }
                }
            })
            
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
        
        Perform.createWordPair(wordPair: newWordPair, enfocaRef: enfocaRef, db: db) { (wordPair:WordPair?, error:String?) in
            
            if let error = error {
                callback(nil, error)
            }
            
            guard let wordPair = wordPair else { return }
            
            self.dataStore.add(wordPair: wordPair)
            
            //Create any tag associations for this new word.
            for tag in tags {
                Perform.createTagAssociation(tagId: tag.tagId, wordPairId: wordPair.pairId, enfocaRef: self.enfocaRef, db: self.db, callback: { (tagAss:TagAssociation?, error:String?) in
                    
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
    
    func updateDictionary(oldDictionary : UserDictionary, termTitle: String, definitionTitle: String, subject : String, language: String?, callback :
        @escaping(UserDictionary?, EnfocaError?)->()) {
        
        oldDictionary.applyUpdate(termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
        Perform.updateDictionary(db: db, dictionary: oldDictionary) { (dictionary: UserDictionary?, error: String?) in
            
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let _ = dictionary else { fatalError() }
            
            callback(dictionary, nil)
            
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
        
        Perform.updateWordPair(wordPair: tuple.0, db: db) { (wp:WordPair?, error:String?) in
            
            if let error = error {
                callback(nil, error)
            }
            notifyOnOpsCompleted()
        }
        
        for tag in tuple.1 {
            Perform.createTagAssociation(tagId: tag.tagId, wordPairId: oldWordPair.pairId, enfocaRef: self.enfocaRef, db: self.db, callback: { (tagAss:TagAssociation?, error:String?) in
                
                if let error = error { callback(nil, error) }
                
                guard let assocation = tagAss else { fatalError() }
                self.dataStore.add(tagAssociation: assocation)
                notifyOnOpsCompleted()
            })
        }
        
        for tagAss in tuple.2 {
            Perform.deleteTagAssociation(tagAssociation: tagAss, db: self.db, callback: { (recordId: String?, error: String?) in
                if let error = error { callback(nil, error) }
                notifyOnOpsCompleted()
            })
        }
        
        
        
    }
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->()){
        
        Perform.createTag(tagName: tagValue, enfocaRef: enfocaRef, db: db) { (tag:Tag?, error: String?) in
            
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
        
        Perform.updateTag(updatedTag: newTag, db: db) { (tag:Tag?, error:String?) in
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
        
        Perform.deleteWordPair(wordPair: wordPair, db: db) { (recordId: String?, error: String?) in
            
            if let error = error {
                callback(nil, error)
                self.showNetworkActivityIndicator = false
            }
            notifyOnOpsCompleted()
            
        }
        
        for associaion in associations {
            Perform.deleteTagAssociation(tagAssociation: associaion, db: db) { (recordId:String?, error:String?) in
                if let error = error {
                    callback(nil, error)
                    self.showNetworkActivityIndicator = false
                }
                notifyOnOpsCompleted()
            }
        }
    }
    
    func deleteDictionary(dictionary: UserDictionary, callback: @escaping(UserDictionary?, EnfocaError?)->()) {
        
        showNetworkActivityIndicator = true
        
        Perform.deleteDictionary(dictionary: dictionary, db: db) { (dictionaryId: String?, error: String?) in
            self.showNetworkActivityIndicator = false
            if let error = error {
                callback(nil, error)
            }
            guard let _ = dictionaryId else { fatalError() }
            
            callback(dictionary, nil)

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
        
        Perform.deleteTag(tag: tag, db: db) { (recordId: String?, error: String?) in
            
            if let error = error {
                callback(nil, error)
                self.showNetworkActivityIndicator = false
            }
            notifyOnOpsCompleted()
            
        }
        
        for associaion in associations {
            Perform.deleteTagAssociation(tagAssociation: associaion, db: db) { (recordId:String?, error:String?) in
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
            
            Perform.updateMetaData(updatedMetaData: currentMetaData, db: privateDb) { (metaData: MetaData?, error: String?) in
                self.showNetworkActivityIndicator = false
                
                if let error = error { callback(nil, error) }
                guard let metaData = metaData else { fatalError() }
                callback(metaData, nil)
            }
        } else {
            //Create
            let newMetaData = MetaData(metaId: "notset", pairId: forWordPair.pairId, dateCreated: Date(), dateUpdated: Date(), incorrectCount: 0, totalTime: 0, timedViewCount: 0)
            
            dataStore.updateScore(metaData: newMetaData, correct: correct, elapsedTime: elapsedTime)
            
            Perform.createMetaData(metaDataSource: newMetaData, enfocaRef: enfocaRef, db: privateDb, callback: { (metaData: MetaData?, error: String?) in
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
    
    
    func getSubject() -> String {
        return dataStore.getSubject()
    }
    
    func getTermTitle() -> String {
        return dataStore.getTermTitle()
    }
    
    func getDefinitionTitle() -> String {
        return dataStore.getDefinitionTitle()
    }
    
    private func initializeCloudKitSubscriptions(callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()) {
        
//        callback(true, nil)
        
        performCloudKitSubscription(forRecord: "WordPair", db: db, callback: callback)
//        performCloudKitSubscription(forRecord: "Tag", db: db, callback: callback)
//        performCloudKitSubscription(forRecord: "TagAssociation", db: db, callback: callback)
//        performCloudKitSubscription(forRecord: "MetaData", db: privateDb, callback: callback)
    }
    
    private func performCloudKitSubscription(forRecord type: String, db: CKDatabase, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()) {
        
        showNetworkActivityIndicator = true
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let subscription = CKQuerySubscription(recordType: type, predicate: predicate, subscriptionID: type, options: [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate])
        
        
        //I dont want badges or notifications, so i'm not messing with CKNotificationInfo
        //Hm, not working without it?.
        
        let info = CKNotificationInfo()
        info.alertBody = "\(type) CRUD"
        info.shouldBadge = false
        
        //https://stackoverflow.com/questions/32081039/how-to-test-that-silent-notifications-are-working-in-ios
//        let info = CKNotificationInfo()
//        info.shouldSendContentAvailable = true
        
        subscription.notificationInfo = info
        
        
        
        db.save(subscription) { (subscription: CKSubscription?, error: Error?) in
//            if let error = error {
//                //TODO: Handle error better?
//                callback(false, "Error while establishing \(type) record subscription. Error\(error)")
//                return
//            }
            
//            guard let subscription = subscription else {
//                
////                if error.domain == "CKErrorDomain" && error.code == 15 {
////                    NSLog("Already set, ignoring dupe")
////                }
//                
////                callback(false, "Error while establishing \(type) record subscription. Error\(error)")
//                
//                callback(true, nil)
//                return
//            }
            
//            self.subscriptionForWordPair = subscription
            
            
            
            //TODO Figure out how to detect if the error is due to duplicate
            invokeLater {
                self.showNetworkActivityIndicator = false
                callback(true, nil)
            }
            
        }
        
        
    }
    
    func remoteWordPairUpdate(pairId: String, callback: @escaping (WordPair)->()) {
        
        let recordId = CKRecordID(recordName: pairId)
        
        db.fetch(withRecordID: recordId) { (record: CKRecord?, error: Error?) in
            guard let record = record else { return }
            
            //Make sure that this record is in the current dictionary!
            
            let wp = CloudKitConverters.toWordPair(from: record)
            
            invokeLater {
                self.dataStore.applyUpdate(wordPair: wp)
                callback(wp)
            }
            
        }
    }
    
    func reloadWordPair(sourceWordPair: WordPair, callback: @escaping (WordPair?, EnfocaError?)->()) {
        
        showNetworkActivityIndicator = true
        
        Perform.reloadTags(db: db, enfocaRef: enfocaRef) { (tags: [Tag]?, error: String?) in
            if let error = error { callback(nil, error) }
            
            guard let tags = tags else { fatalError() }
            
            Perform.reloadWordPair(db: self.db, enfocaRef: self.enfocaRef, sourceWordPair: sourceWordPair) { (tuple: (WordPair, [TagAssociation])?, error:String?) in
                
                if let error = error { callback(nil, error) }
                
                guard let tuple = tuple else { fatalError() }
                
                let wp = tuple.0
                let tagAsses = tuple.1
                
                self.dataStore.reload(wordPair: wp, withTagAssociations: tagAsses, updatedTagList: tags)
//                self.dataStore.applyUpdate(wordPair: wp)
                //TODO: Handle the asses too.  //But also dont forget to refresh the tags.
                
                self.showNetworkActivityIndicator = false
                
                callback(wp, nil)
                
            }
            
        }
        
        
        
    }
    
//    func fetchChanges() {
////        db.fetchAllSubscriptions(completionHandler: <#T##([CKSubscription]?, Error?) -> Void#>)
//        var sub = CKSubscription
//        CKFetchDatabaseChangesOperation(previousServerChangeToken: <#T##CKServerChangeToken?#>)
//        
//        CKFetchRecordZoneChangesOperation(
//    }
    
}
