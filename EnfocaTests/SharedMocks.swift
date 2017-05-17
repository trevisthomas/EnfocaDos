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
    
    init() {
        self.tags = makeTags()
    }
    
    func initialize(callback: @escaping (Bool, EnfocaError?) -> ()) {
        callback(true, nil)
    }
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()){
        fetchUserTagsCallCount += 1
        callback(tags, nil)
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
        
    }
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()){}
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){}
    
}

class MockDefaults : ApplicationDefaults {
    var reverseWordPair: Bool = false
    var saveCount = 0
    var selectedTags: [Tag] = []
    var tags: [Tag] = []
    var dataStore: DataStore!
    
    var fetchWordPairPageSize: Int {
        return 10
    }
    
    func save() {
        saveCount += 1
    }
    
    func load() {
        
    }
}

