//
//  UiTestWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class UiTestWebService : WebService {
    private(set) var enfocaId : NSNumber!
    private var dataStore: DataStore!
    
//    var tags: [Tag]
//    var wordPairs: [WordPair]
    private var guidIndex = 0
    
    
    
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

    
    func initialize(json: String?, progressObserver: ProgressObserver, callback: @escaping (_ success : Bool, _ error : EnfocaError?) -> ()){
        
        
        //TODO: load from json
        
        dataStore = DataStore()
        
        if let json = json {
            dataStore.initialize(json: json)
        } else {
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
    
    func createTag(tagValue: String, callback: @escaping(Tag?, EnfocaError?)->()){
        
        let tag = Tag(tagId: "\(nextIndex())", name: tagValue)
        
        showNetworkActivityIndicator = true
        
        dataStore.add(tag: tag)
        invokeLater {
            self.showNetworkActivityIndicator = false
            callback(tag, nil)
        }
        
    }
    
    func updateTag(oldTag : Tag, newTagName: String, callback: @escaping(Tag?, EnfocaError?)->()) {
        showNetworkActivityIndicator = true
        let newTag = dataStore.applyUpdate(oldTag: oldTag, name: newTagName)
        
       
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
}
