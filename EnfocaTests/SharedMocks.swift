//
//  SharedMocks.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/26/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit
import CloudKit
@testable import Enfoca


class MockWebService : WebService {
    var fetchWordPairTagFilter : [Tag]?
    var fetchWordPairCallCount : Int = 0
    var wordPairs : [WordPair] = []
    var fetchWordPairOrder : WordPairOrder?
    var fetchWordPairPattern : String?
    
    var activateCalled : Bool = false
    var activeCalledWithWordPair : WordPair!
    
    var deactivateCalled : Bool = false
    var deactiveCalledWithWordPair : WordPair!
    
    var createCalledCount: Int = 0
    var updateCalledCount: Int = 0
    
    var createdWordPair: WordPair?
    var updatedWordPair: WordPair?
    
    var metaDict: [String: MetaData] = [:]
    
    var dictionary: UserDictionary!
    
    var showNetworkActivityIndicatorCalledCount = 0
    var showNetworkActivityIndicator: Bool = false {
        didSet{
            showNetworkActivityIndicatorCalledCount += 1
        }
    }
    
    //Set this to non null values to get errors back in your test
    var errorOnCreateWordPair : String?
    var errorOnUpdateWordPair : String?
    
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder : WordPairOrder, pattern : String? = nil, callback: @escaping ([WordPair]?, EnfocaError?) -> ()) {
        fetchWordPairTagFilter = tagFilter
        fetchWordPairCallCount += 1
        fetchWordPairOrder = wordPairOrder
        fetchWordPairPattern = pattern
        
        callback(wordPairs, nil)
    }
    
    func wordPairCount(tagFilter: [Tag], pattern: String?, callback: @escaping (Int?, EnfocaError?) -> ()) {
        fetchWordPairTagFilter = tagFilter
        fetchWordPairCallCount += 1
//        fetchWordPairOrder = wordPairOrder
        fetchWordPairPattern = pattern
        
        callback(wordPairs.count, nil)
    }
    
    var fetchUserTagsCallCount : Int = 0
    var tags : [Tag] = []
    
    convenience init(tags : [Tag]) {
        self.init()
        self.tags = tags
    }
    
    func prepareDataStore(dictionary: UserDictionary?, dataStore: DataStore?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()) {
        self.tags = makeTags()
        
        self.dictionary = dictionary
    }
    
    
    func serialize() -> String?{
        return nil
    }
    

    
    func initialize(callback: @escaping (Bool, EnfocaError?) -> ()) {
        callback(true, nil)
    }
    
    var fetchUserTagsError: String?
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()){
        fetchUserTagsCallCount += 1
        
        if let error = fetchUserTagsError {
            callback(nil, error)
        } else {
            callback(tags, nil)
        }        
    }
    
//    func activateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
//        activateCalled = true
//        activeCalledWithWordPair = wordPair
//        callback!(true)
//    }
//    
//    func deactivateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
//        deactivateCalled = true
//        deactiveCalledWithWordPair = wordPair
//        callback!(true)
//    }
    

    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String? = nil, callback : @escaping(WordPair?, EnfocaError?)->()) {
        
        createCalledCount += 1
        
        if let error = errorOnCreateWordPair {
            callback(nil, error)
            return
        }
        
        createdWordPair = WordPair(pairId: "none", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(createdWordPair, nil)
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String? = nil, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()) {
        
        updateCalledCount += 1
        
        if let error = errorOnUpdateWordPair {
            callback(nil, error)
            return
        }
        
        updatedWordPair = WordPair(pairId: oldWordPair.pairId, word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(updatedWordPair, nil)
        
        
    }
    
    func fetchNextWordPairs(callback : @escaping([WordPair]?,EnfocaError?)->()){
    }
    
    var errorOnCreateTag : String? = nil
    var createTagCallCount = 0
    var createTagValue : String? = nil
    var createTagBlockedCallback : ((Tag?, EnfocaError?)->())?
    var createTagBlockCallback : Bool = false
    
    func createTag(tagValue: String, callback: @escaping (Tag?, EnfocaError?) -> ()) {
        
        createTagCallCount += 1
        createTagValue = tagValue
        
        if let error = errorOnCreateTag {
            callback(nil, error)
            return
        } else {
            let t = Tag(tagId: "eyedee", name: tagValue)
            if (createTagBlockCallback) {
                createTagBlockedCallback = callback
            } else {
                callback(t, nil)
            }
        }
    }
    
    func updateTag(oldTag : Tag, newTagName: String, callback: @escaping(Tag?, EnfocaError?)->()) {
        
        callback(Tag(tagId: oldTag.tagId, name: newTagName), nil)
    }
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()){}
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){}
    
    func fetchQuiz(forTag: Tag?, cardOrder: CardOrder, wordCount: Int, callback: @escaping ([WordPair]?, EnfocaError?) -> ()) {
        callback(wordPairs, nil)
    }
    
    
    var metaId = 0
    func updateScore(forWordPair: WordPair, correct: Bool, elapsedTime: Int, callback: @escaping (MetaData?, EnfocaError?) -> ()) {
        metaId += 1
        
//        fatalError()
        
        invokeLater {
            var oldTimedViewCount = 0
            var oldIncorrectCount = 0
            var oldCreateDate = Date()
//            if let oldMeta = forWordPair.metaData {
//                oldTimedViewCount = oldMeta.timedViewCount
//                oldIncorrectCount = oldMeta.incorrectCount
//                oldCreateDate = oldMeta.dateCreated
//            }
            
            if !correct {
                oldIncorrectCount += 1
            }
            oldTimedViewCount += 1
            
            let meta = MetaData(metaId: "meta\(self.metaId)", pairId: forWordPair.pairId, dateCreated: oldCreateDate, dateUpdated: Date(), incorrectCount: oldIncorrectCount, totalTime: -1, timedViewCount: oldTimedViewCount + elapsedTime)
            
            callback(meta, nil)
        }
    }
    
    func fetchMetaData(forWordPair: WordPair, callback: @escaping (MetaData?, EnfocaError?) -> ()) {
        
        callback(metaDict[forWordPair.pairId], nil)
        
    }
    
    func createDictionary(termTitle: String, definitionTitle: String, subject: String, language: String?, callback : @escaping(UserDictionary?, EnfocaError?)->()) {
        fatalError()
    }
    
    func updateDictionary(oldDictionary : UserDictionary, termTitle: String, definitionTitle: String, subject : String, language: String?, callback :
        @escaping(UserDictionary?, EnfocaError?)->()) {
        
        fatalError()
    }
    
    func initialize(callback : @escaping([UserDictionary]?, EnfocaError?)->()){
        fatalError()
    }
    
    func getSubject() -> String {
        return dictionary.subject
    }
    
    func getTermTitle() -> String {
        return dictionary.termTitle
    }
    
    func getDefinitionTitle() -> String {
        return dictionary.definitionTitle
    }
    
    func deleteDictionary(dictionary: UserDictionary, callback: @escaping(UserDictionary?, EnfocaError?)->()) {
        fatalError()
    }
    
    func remoteWordPairUpdate(pairId: String, callback: @escaping (WordPair)->()) {
        fatalError()
    }
    
    func reloadWordPair(sourceWordPair: WordPair, callback: @escaping ((WordPair, MetaData?)?, EnfocaError?)->()) {
        fatalError()
    }
    
    func isDataStoreSynchronized(callback: @escaping (Bool?, String?)->()) {
        fatalError()
    }
    
    func isDataStoreSynchronized(dictionary: UserDictionary, callback: @escaping (Bool?, String?)->()) {
        fatalError()
    }
    
    func reloadTags(callback : @escaping([Tag]?, EnfocaError?)->()) {
        fatalError()
    }
    
    func getCurrentDictionary() -> UserDictionary {
         fatalError()
    }
    
    func updateDictionaryCounts(callback : @escaping(UserDictionary?, EnfocaError?)->()) {
        fatalError()
    }
    
    func fetchCurrentConch(dictionary: UserDictionary, callback: @escaping (String?, String?)->()) {
        fatalError()
    }
    
    func toData() -> Data {
        fatalError()
    }
}

//class MockApplicationDefaults : ApplicationDefaults {
//    var reverseWordPair : Bool = false
//    var selectedTags : [Tag] = []
//    var fetchWordPairPageSize : Int = 10
//    var saveCount = 0
//    func save(includingDataStore json: String?) {
//        saveCount += 1
//    }
//    func load() -> String? {
//        fatalError()
//    }
//    
//    var cardOrder: CardOrder = CardOrder.hardest
//    var cardSide: CardSide = CardSide.random
//    var quizWordCount: Int = 5
//    
//    var wordPairOrder: WordPairOrder = WordPairOrder.wordAsc
//}



