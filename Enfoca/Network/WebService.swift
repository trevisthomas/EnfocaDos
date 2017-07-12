//
//  WebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

protocol WebService {
    
    var showNetworkActivityIndicator : Bool {get set}
    
    func prepareDataStore(dictionary: UserDictionary?, dataStore: DataStore?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ())
    func serialize() -> String?
    
    func toData() -> Data 
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->())
    
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair]?,EnfocaError?)->())
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->());
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->());
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->())
    
    func updateTag(oldTag : Tag, newTagName: String, callback: @escaping(Tag?, EnfocaError?)->())
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->())
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->())
    
    func deleteDictionary(dictionary: UserDictionary, callback: @escaping(UserDictionary?, EnfocaError?)->())
    
    /**
     A null tag is how you ask for words of any tag.
     */
    func fetchQuiz(forTag: Tag?, cardOrder: CardOrder, wordCount: Int, callback: @escaping([WordPair]?, EnfocaError?)->())
    
    func updateScore(forWordPair: WordPair, correct: Bool, elapsedTime: Int, callback: @escaping(MetaData?, EnfocaError?)->())
    
    func fetchMetaData(forWordPair: WordPair, callback: @escaping(MetaData?, EnfocaError?)->())
    
    func initialize(callback : @escaping([UserDictionary]?, EnfocaError?)->())
    
    func createDictionary(termTitle: String, definitionTitle: String, subject: String, language: String?, callback : @escaping(UserDictionary?, EnfocaError?)->())
    
    func updateDictionary(oldDictionary : UserDictionary, termTitle: String, definitionTitle: String, subject : String, language: String?, callback :
        @escaping(UserDictionary?, EnfocaError?)->())
    
    func getSubject() -> String
    
    func getTermTitle() -> String
    
    func getDefinitionTitle() -> String
    
    //Maybe deprecated.  This was while i was messing with those horible subscriptions
    func remoteWordPairUpdate(pairId: String, callback: @escaping (WordPair)->())
    
    func reloadWordPair(sourceWordPair: WordPair, callback: @escaping ((WordPair, MetaData?)?, EnfocaError?)->())
    
    func isDataStoreSynchronized(callback: @escaping (Bool?, String?)->())
    
    func isDataStoreSynchronized(dictionary: UserDictionary, callback: @escaping (Bool?, String?)->())
    
    func reloadTags(callback : @escaping([Tag]?, EnfocaError?)->())
    
    func getCurrentDictionary() -> UserDictionary
    
    func updateDictionaryCounts(callback : @escaping(UserDictionary?, EnfocaError?)->())
    
    func fetchCurrentConch(dictionary: UserDictionary, callback: @escaping (String?, String?)->())
    
}
