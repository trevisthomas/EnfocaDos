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
    
    func initialize(json: String?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ())
    func serialize() -> String?
    
    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->())
    
    func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern : String?, callback : @escaping([WordPair]?,EnfocaError?)->())
    
    func fetchNextWordPairs(callback : @escaping([WordPair]?,EnfocaError?)->())

    func wordPairCount(tagFilter: [Tag], pattern : String?, callback : @escaping(Int?, EnfocaError?)->())
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->());
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->());
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->())
    
    func updateTag(oldTag : Tag, newTagName: String, callback: @escaping(Tag?, EnfocaError?)->())
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->())
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->())
    
    /**
     A null tag is how you ask for words of any tag.
     */
    func fetchQuiz(forTag: Tag?, cardOrder: CardOrder, wordCount: Int, callback: @escaping([WordPair]?, EnfocaError?)->())
    
    func updateScore(forWordPair: WordPair, correct: Bool, callback: @escaping(MetaData?, EnfocaError?)->())
    
    func fetchMetaData(forWordPair: WordPair, callback: @escaping(MetaData?, EnfocaError?)->())
}
