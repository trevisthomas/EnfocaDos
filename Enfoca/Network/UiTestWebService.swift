//
//  UiTestWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class UiTestWebService : WebService {
    private(set) var dictionary: UserDictionary!
    private(set) var enfocaId : NSNumber!
    private var dataStore: DataStore!
    
//    var tags: [Tag]
//    var wordPairs: [WordPair]
    private var guidIndex = 0
    
    func toData() -> Data? {
        fatalError()
    }
    
    var showNetworkActivityIndicator: Bool {
        get {
            return UIApplication.shared.isNetworkActivityIndicatorVisible
        }
        set {
            UIApplication.shared.isNetworkActivityIndicatorVisible = newValue
        }
    }
    
    private func nextIndex() -> Int{
        guidIndex += 1
        return guidIndex
    }

    
//    private func makeWordPairWithTag(word: String, definition: String, tags : [Tag]) -> WordPair{
//        let wp = WordPair( pairId: "1-0-0-1\(nextIndex())", word: word, definition: definition, dateCreated: Date(), tags : tags)
//        return wp
//    }
//    
//    private func makeWordPair(word: String, definition: String) -> WordPair{
//        return WordPair( pairId: "1-0-0-1\(nextIndex())", word: word, definition: definition, dateCreated: Date())
//    }
    
//    private func makeTags() -> [Tag] {
//        var tags: [Tag] = []
//        tags.append(Tag(tagId: "\(nextIndex())", name: "Noun"))
//        tags.append(Tag(tagId: "\(nextIndex())", name: "Verb"))
//        tags.append(Tag(tagId: "\(nextIndex())", name: "Phrase"))
//        tags.append(Tag(tagId: "\(nextIndex())", name: "Adverb"))
//        
//        return tags
//    }

    
    func prepareDataStore(dictionary: UserDictionary?, dataStore ds: DataStore?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        
        if let ds = ds {
            dataStore = ds
        } else {
            
            guard let dictionary = dictionary else { fatalError() }
            
            dataStore = DataStore(dictionary: dictionary)
            
            //Load it mockly
            var tags: [Tag] = []
            tags.append(Tag(tagId: "\(nextIndex())", name: "Color"))
            tags.append(Tag(tagId: "\(nextIndex())", name: "Noun"))
            tags.append(Tag(tagId: "\(nextIndex())", name: "Verb"))
            tags.append(Tag(tagId: "\(nextIndex())", name: "Adjective"))

            for t in tags {
                dataStore.add(tag: t)
            }
            
//            dataStore.add(wordPair: WordPair(pairId: "\(nextIndex())", word: "rojo", definition: "red", dateCreated: Date()))
//            dataStore.add(wordPair: WordPair(pairId: "\(nextIndex())", word: "mujer", definition: "woman", dateCreated: Date()))
//            dataStore.add(wordPair: WordPair(pairId: "\(nextIndex())", word: "to run", definition: "correr", dateCreated: Date()))
//            dataStore.add(wordPair: WordPair(pairId: "\(nextIndex())", word: "fuerte", definition: "strong", dateCreated: Date()))
            
            createWordPair(word: "rojo", definition: "red", tags: [tags[0]], gender: .notset, example: nil, callback: { (_ : WordPair?, _:EnfocaError?) in
                //nothing
            })
            
            createWordPair( word: "mujer", definition: "woman", tags: [tags[1]], gender: .notset, example: nil, callback: { (_ : WordPair?, _:EnfocaError?) in
                //nothing
            })
            
            createWordPair(word: "correr", definition: "to run", tags: [tags[2]], gender: .notset, example: nil, callback: { (_ : WordPair?, _:EnfocaError?) in
                //nothing
            })
            
            createWordPair(word: "fuerte", definition: "strong", tags: [tags[3]], gender: .notset, example: nil, callback: { (_ : WordPair?, _:EnfocaError?) in
                //nothing
            })
            
            
        }
        
        invokeLater {
            callback(true, nil)
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
        
        showNetworkActivityIndicator = true
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(sorted, nil)
        }
        
        
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String?, callback : @escaping(WordPair?, EnfocaError?)->()){
        
        let newWordPair = WordPair(pairId: "\(nextIndex())", word: word, definition: definition, dateCreated: Date())
        
        self.dataStore.add(wordPair: newWordPair)
        
        for t in tags {
            let ass = TagAssociation(associationId: "\(nextIndex())", wordPairId: newWordPair.pairId, tagId: t.tagId)
            dataStore.add(tagAssociation: ass)
        }
    
        
        showNetworkActivityIndicator = true
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(newWordPair, nil)
        }
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()){
        
        let tuple = dataStore.applyUpdate(oldWordPair: oldWordPair, word: word, definition: definition, gender: gender, example: example, tags: tags)
        
        
        for t in tuple.1 {
            let ass = TagAssociation(associationId: "\(nextIndex())", wordPairId: tuple.0.pairId, tagId: t.tagId)
            dataStore.add(tagAssociation: ass)

        }
        
        showNetworkActivityIndicator = true
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(tuple.0, nil)
        }
        
    }
    
    func createTag(fromTag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){
        
        let tag = Tag(tagId: "\(nextIndex())", name: fromTag.name)
        
        showNetworkActivityIndicator = true
        
        dataStore.add(tag: tag)
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(tag, nil)
        }
        
    }
    
    func updateTag(oldTag : Tag, updatedTag: Tag, callback: @escaping(Tag?, EnfocaError?)->()) {
        showNetworkActivityIndicator = true
        let newTag = dataStore.applyUpdate(oldTag: oldTag, name: updatedTag.name, color: updatedTag.color)
        
       
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(newTag, nil)
        }
       
    }
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()) {
        
        let _ = dataStore.remove(wordPair: wordPair)
        
        
        showNetworkActivityIndicator = true
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(wordPair, nil)
        }
        
    }
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){
        let _ = dataStore.remove(tag: tag)
        
        showNetworkActivityIndicator = true
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(tag, nil)
        }
        
    }
    
    func fetchQuiz(forTag: Tag?, cardOrder: CardOrder, wordCount: Int, callback: @escaping ([WordPair]?, EnfocaError?) -> ()) {
        fatalError()
    }
    
    func updateScore(forWordPair: WordPair, correct: Bool, elapsedTime: Int, callback: @escaping (MetaData?, EnfocaError?) -> ()) {
        fatalError()
    }
    
    func fetchMetaData(forWordPair: WordPair, callback: @escaping (MetaData?, EnfocaError?) -> ()) {
        callback(dataStore.getMetaData(forWordPair: forWordPair), nil)
    }
    
    func initialize(callback: @escaping ([UserDictionary]?, EnfocaError?) -> ()) {
        callback([], nil) //Hm
    }
    
    func createDictionary(termTitle: String, definitionTitle: String, subject: String, language: String?, callback: @escaping (UserDictionary?, EnfocaError?) -> ()) {
        fatalError()
    }
    
    func updateDictionary(oldDictionary : UserDictionary, termTitle: String, definitionTitle: String, subject : String, language: String?, callback :
        @escaping(UserDictionary?, EnfocaError?)->()){
        
        fatalError()
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

    func deleteDictionary(dictionary: UserDictionary, callback: @escaping(UserDictionary?, EnfocaError?)->()) {
        fatalError()
    }
    
    
    func remoteWordPairUpdate(pairId: String, callback: @escaping (WordPair)->()) {
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
    
    func reloadWordPair(sourceWordPair: WordPair, callback: @escaping ((WordPair, MetaData?)?, EnfocaError?)->()) {
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
}
