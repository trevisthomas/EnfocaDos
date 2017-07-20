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
    private let userDictionaryListKey = "userDictionaryListKey"
    var isNetworkAvailable: Bool = false
    private var enfocaRef: CKReference!
    private var subscriptionForWordPair: CKSubscription?
    private(set) var db : CKDatabase!
    private(set) var privateDb : CKDatabase!
    private(set) var userRecordId : CKRecordID!  //Not really using this here.
    private var isDataStoreSynchronized: Bool = true
    private var dataStore: DataStore! {
        didSet{
            let recordId = CloudKitConverters.toCKRecordID(fromRecordName: dataStore.getUserDictionary().enfocaRef)
            enfocaRef = CKReference(recordID: recordId, action: .none)
            
            
            print("EnfocaRef: \(enfocaRef.recordID.recordName)")
        }
    }
    
    init(isNetworkAvailable: Bool) {
        self.isNetworkAvailable = isNetworkAvailable
    }
    
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
    private func loadUserRecordFromDefaults() -> [UserDictionary]? {
        let defaults = UserDefaults.standard
        guard let data = defaults.value(forKey: userDictionaryListKey) as? Data else {
            return nil
        }
        guard let list = NSKeyedUnarchiver.unarchiveObject(with: data) as? [UserDictionary] else { fatalError("Corrupt local user dictionaries.") }
        
        return list
    }
    
    private func saveUserRecordToDefaults(_ dictionaryList: [UserDictionary]) {
        let defaults = UserDefaults.standard
        
        let data = NSKeyedArchiver.archivedData(withRootObject: dictionaryList)
        
        defaults.set(data, forKey: userDictionaryListKey)
    }
    
    //This needs to be called first to initialize the things.  
    //It will eventually replace the old init method.
    //TODO: Rename to pre-initialize?
    func initialize(callback : @escaping([UserDictionary]?, EnfocaError?)->()){
        guard isNetworkAvailable else {
            guard let cachedDictionaries = loadUserRecordFromDefaults() else {
                callback(nil, "Local cache has no dictionaries")
                return
            }
            callback(cachedDictionaries, nil)
            return
        }
        
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
            
            self.saveUserRecordToDefaults(tuple.1)
          
            callback(tuple.1, nil)
        }
    }
    
    func createDictionary(termTitle: String, definitionTitle: String, subject: String, language: String? = nil, callback : @escaping(UserDictionary?, EnfocaError?)->()) {
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        showNetworkActivityIndicator = true
        
        let dictionary = UserDictionary(dictionaryId: "not-set", userRef: userRecordId.recordName, enfocaRef: "not-set-generated-by-this-method", termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
        //Remember, this method generates an enfoca id. Well it used to.  I guess it's a ref now
        Perform.createDictionary(db: db, dictionary: dictionary) { (dictionary: UserDictionary?, error: String?) in
            
            if let error = error { callback(nil, error) }
            
            guard let dictionary = dictionary else { fatalError("Failed to create dictionary") }
            
            let recordId = CloudKitConverters.toCKRecordID(fromRecordName: dictionary.enfocaRef)
            let tempRef = CKReference(recordID: recordId, action: .none)
            
            Perform.loadOrCreateConch(enfocaRef: tempRef, db: self.db, allowCreation: true, callback: { (tuple:(String, Bool)?, error: EnfocaError?) in
                if let error = error { callback(nil, error) }
                guard let tuple = tuple else { fatalError() }
                dictionary.conch = tuple.0
                delay(delayInSeconds: 2, callback: {
                    //Giving cloud kit time to really have this record. :-(
                    callback(dictionary, nil)
                })
                
            })
        }
    }
    
    func prepareDataStore(dictionary: UserDictionary?, dataStore: DataStore?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        showNetworkActivityIndicator = true
        
        isDataStoreSynchronized = true
        
        let ds: DataStore
        
        if let dataStore = dataStore {
            ds = dataStore
        } else if let dictionary = dictionary {
            guard let _ = dictionary.conch else { fatalError("conches are not option at this point anymore") }
            ds = DataStore(dictionary: dictionary)
        } else {
            fatalError() //I need one or the other.
        }
        
        if ds.isInitialized {
            ds.register(anyTag: getAppDelegate().applicationDefaults.anyTag, noneTag: getAppDelegate().applicationDefaults.noneTag)
            
            print("DataStore recreated via cache")
            self.dataStore = ds
            
            invokeLater {
                //                self.initializeCloudKitSubscriptions(callback: callback)
                self.showNetworkActivityIndicator = false
                callback(true, nil)
            }
            
            return
        } else {
            print("DataStore needs to be loaded from iCloud")
            
            let recordId = CloudKitConverters.toCKRecordID(fromRecordName: ds.getUserDictionary().enfocaRef)
            let tempRef = CKReference(recordID: recordId, action: .none)
            
            Perform.initializeDataStore(dataStore: ds, enfocaRef: tempRef, db: self.db, privateDb: self.privateDb, progressObserver: progressObserver) { (ds : DataStore?, error: EnfocaError?) in
                invokeLater {
                    if let error = error {
                        callback(false, error)
                    }
                    guard let dataStore = ds else {
                        callback(false, "DataStore was nil.  This is a fatal error.")
                        return;
                    }
                    
                    dataStore.register(anyTag: getAppDelegate().applicationDefaults.anyTag, noneTag: getAppDelegate().applicationDefaults.noneTag)
                    
                    self.dataStore = dataStore
                    //                    self.initializeCloudKitSubscriptions(callback: callback)
                    self.showNetworkActivityIndicator = false
                    callback(true, nil)
                }
            }
        }
    }
    
    
    func serialize() -> String? {
        return dataStore.toJson()
    }
    
    func toData() -> Data? {
        if dataStore == nil {
            return nil
        }
        return NSKeyedArchiver.archivedData(withRootObject: dataStore)
    }
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()) {
        callback(dataStore.allTags(), nil)
    }
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair]?,EnfocaError?)->()){
        
        let sorted = dataStore.search(wordPairMatching: pattern ?? "", order: wordPairOrder, withTags: tagFilter)
        callback(sorted, nil)
        
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->()){
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        resetConchIfOutOfSynch()
        
        let newWordPair = WordPair(pairId: "", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        
        Perform.createWordPair(wordPair: newWordPair, enfocaRef: enfocaRef, db: db) { (wordPair:WordPair?, error:String?) in
            
            if let error = error {
                callback(nil, error)
            }
            
            guard let wordPair = wordPair else { return }
            
            self.dataStore.add(wordPair: wordPair)
            
            self.updateDictionaryCounts()
            
            //Create any tag associations for this new word.
            
            if tags.count > 0 {
                var countdownLatchSortOfThing = tags.count
                for tag in tags {
                    Perform.createTagAssociation(tagId: tag.tagId, wordPairId: wordPair.pairId, enfocaRef: self.enfocaRef, db: self.db, callback: { (tagAss:TagAssociation?, error:String?) in
                        
                        if let error = error {
                            callback(nil, error)
                        }

                        guard let association = tagAss else { return }
                        
                        self.dataStore.add(tagAssociation: association)
                        countdownLatchSortOfThing = countdownLatchSortOfThing - 1
                        
                        if countdownLatchSortOfThing == 0 {
                            callback(wordPair, nil)
                        } 
                    })
                }
            } else {
                callback(wordPair, error)
            }
        }
    }
    
    func updateDictionary(oldDictionary : UserDictionary, termTitle: String, definitionTitle: String, subject : String, language: String?, callback :
        @escaping(UserDictionary?, EnfocaError?)->()) {
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
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
    
    func updateDictionaryCounts(callback :
        @escaping(UserDictionary?, EnfocaError?)->() = { _,_ in }) {
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        let currentDict = dataStore.getUserDictionary(refreshCounts: true)
        
        Perform.updateDictionary(db: db, dictionary: currentDict) { (dictionary: UserDictionary?, error: String?) in
            
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
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        resetConchIfOutOfSynch()
        
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
                
                self.updateDictionaryCounts()
            })
        }
        
        for tagAss in tuple.2 {
            Perform.deleteTagAssociation(tagAssociation: tagAss, db: self.db, callback: { (recordId: String?, error: String?) in
                if let error = error { callback(nil, error) }
                notifyOnOpsCompleted()
            })
        }
        
        
        
    }
    
    func createTag(fromTag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){
        resetConchIfOutOfSynch()
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        showNetworkActivityIndicator = true
        Perform.createTag(fromTag: fromTag, enfocaRef: enfocaRef, db: db) { (tag:Tag?, error: String?) in
            self.showNetworkActivityIndicator = false
            if let error = error {
                callback(nil, error)
            }
            
            guard let tag = tag else { fatalError() }
            
            self.dataStore.add(tag: tag)
            
            self.updateDictionaryCounts()
            
            callback(tag, nil)
        }
        
        
    }
    
    func updateTag(oldTag : Tag, updatedTag: Tag, callback: @escaping(Tag?, EnfocaError?)->()) {
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        resetConchIfOutOfSynch()
        showNetworkActivityIndicator = true
        
        oldTag.applyUpdate(name: updatedTag.name, color: updatedTag.color)
        
        Perform.updateTag(updatedTag: oldTag, db: db) { (tag:Tag?, error:String?) in
            self.showNetworkActivityIndicator = false
            
            if let error = error { callback(nil, error) }
            
            guard let tag = tag else { fatalError() }
            
            callback(tag, nil)
        }
    }
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()) {
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        showNetworkActivityIndicator = true
        resetConchIfOutOfSynch()
        let associations = dataStore.remove(wordPair: wordPair)
        
        self.updateDictionaryCounts()
        
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
        
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        showNetworkActivityIndicator = true
        
        Perform.deleteDictionary(dictionary: dictionary, db: db, privateDb: privateDb) { (dictionaryId: String?, error: String?) in
            self.showNetworkActivityIndicator = false
            if let error = error {
                callback(nil, error)
            }
            guard let _ = dictionaryId else { fatalError() }
            
            callback(dictionary, nil)

        }
    }
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){
        guard isNetworkAvailable else {
            callback(nil, "Network connection is unavailable.")
            return
        }
        
        showNetworkActivityIndicator = true
        
        resetConchIfOutOfSynch()
        let associations = dataStore.remove(tag: tag)
        
        self.updateDictionaryCounts()
        
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
        
        guard isNetworkAvailable else {
            callback(metaData, nil)
            showNetworkActivityIndicator = false
            return
        }
        
        if let currentMetaData = metaData {
            Perform.updateMetaData(oldMetaData: currentMetaData, isCorrect: correct, elapsedTime: elapsedTime, db: privateDb) { (metaData: MetaData?, error: String?) in
                self.showNetworkActivityIndicator = false
                
                if let error = error { callback(nil, error) }
                guard let metaData = metaData else { fatalError() }
                
                self.dataStore.add(metaData: metaData)
                
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
                
                self.updateDictionaryCounts()
                callback(metaData, nil)
            })
        }
        
    }
    
    func fetchMetaData(forWordPair wordPair: WordPair, callback: @escaping(MetaData?, EnfocaError?)->()) {
        let meta = dataStore.getMetaData(forWordPair: wordPair)
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
        fatalError()
//        let recordId = CKRecordID(recordName: pairId)
//        
//        db.fetch(withRecordID: recordId) { (record: CKRecord?, error: Error?) in
//            guard let record = record else { return }
//            
//            //Make sure that this record is in the current dictionary!
//            
//            let wp = CloudKitConverters.toWordPair(from: record)
//            
//            invokeLater {
//                self.dataStore.applyUpdate(wordPair: wp)
//                callback(wp)
//            }
//            
//        }
    }
    
    
    //NOTE: Be aware that reloading the tags like this is a blunt tool which can leave the datastore out of synch with the DB.  The thought was that if i make the list in synch early that i can prevent an out of synch client from being able to tag a word with a tag that has been deleted.  
    
    //TODO: Seriously consider deleting orphaned tags, or something.
    func reloadTags(callback : @escaping([Tag]?, EnfocaError?)->()) {
        Perform.reloadTags(db: db, enfocaRef: enfocaRef) { (tags: [Tag]?, error: String?) in
            if let error = error { callback(nil, error) }
            invokeLater {
                guard let tags = tags else { fatalError() }
                self.dataStore.reload(updatedTagList: tags)
                callback(self.dataStore.allTags(), nil)
            }
        }
    }
    
    func reloadWordPair(sourceWordPair: WordPair, callback: @escaping ((WordPair, MetaData?)?, EnfocaError?)->()) {
        
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
                
                //Should probably, maybe really reload meta.
                let meta = self.dataStore.getMetaData(forWordPair: wp)
                callback((wp, meta), nil)
                
            }
            
        }
    }
    
    private func resetConchIfOutOfSynch() {
        isDataStoreSynchronized { (inSynch: Bool?, error: String?) in
        
            guard let inSynch = inSynch else { fatalError("Conch was nil.  Fatal error.") }
            
            Perform.resetConch(enfocaRef: self.enfocaRef, db: self.db, callback: { (newConch: String?, error: EnfocaError?) in
                
                if let error = error {
                    print(error) //This happened in dev because i didnt grant non-creators to write
                    //Retry?
                }
                
                
                guard let conch = newConch else { fatalError() }
                if inSynch {
                    //If we were in synch prior to updating the conch, we store this new conch to continue being in synch,
                    //If we were not in synch, we let our conch go stale but we continue to update the server
                    
                    invokeLater {
                        self.dataStore.getUserDictionary().conch = conch
//                        getAppDelegate().saveDefaults() //Hm kinda heavy no?
                    }
                }
            })
        }
    }
    
    func fetchCurrentConch(dictionary: UserDictionary, callback: @escaping (String?, String?)->()) {
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: dictionary.enfocaRef)
        let tempRef = CKReference(recordID: recordId, action: .none)
        
        Perform.loadOrCreateConch(enfocaRef: tempRef, db: db, allowCreation: false) { (tuple : (String, Bool)?, error: EnfocaError?) in
            
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let tuple = tuple else {
                invokeLater {
                    callback(nil, "Conch was nil")
                }
                return
            }
            
            let serverConch = tuple.0
            
            invokeLater {
                callback(serverConch, nil)
            }
        }
    }
    
    func isDataStoreSynchronized(dictionary: UserDictionary, callback: @escaping (Bool?, String?)->()) {
        
        guard isNetworkAvailable else {
            callback(true, nil)
            return
        }
        
        if !isDataStoreSynchronized {
            //If the DS it out of sync, there is no point in checking the DB.  You need to reload.
            callback(false, nil)
            return
        }
        
//        guard let enfocaRef = enfocaRef else { return } //If someone tries to sync before loading, this happens.
        
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: dictionary.enfocaRef)
        let tempRef = CKReference(recordID: recordId, action: .none)
        
        Perform.loadOrCreateConch(enfocaRef: tempRef, db: db, allowCreation: false) { (tuple : (String, Bool)?, error: EnfocaError?) in
            
            if let error = error {
                callback(nil, error)
                return
            }
            
            guard let tuple = tuple else {
                invokeLater {
                    callback(nil, "Conch was nil")
                }
                return
            }
            
            let localConch = dictionary.conch
            let serverConch = tuple.0
            
            self.isDataStoreSynchronized = localConch == serverConch
            invokeLater {
                callback(self.isDataStoreSynchronized, nil)
            }
        }

    }
    
    func isDataStoreSynchronized(callback: @escaping (Bool?, String?)->()) {
        
        if self.dataStore == nil {
            return
        }
        
        isDataStoreSynchronized(dictionary: self.dataStore.getUserDictionary(), callback: callback)
    }
    
    func getCurrentDictionary() -> UserDictionary {
        return dataStore.getUserDictionary()
    }
}
