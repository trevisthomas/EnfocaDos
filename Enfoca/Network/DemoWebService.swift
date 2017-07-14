//
//  DemoWebService.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

class DemoWebService : WebService {
    

    func toData() -> Data {
        fatalError()
    }

    
    /**
     A null tag is how you ask for words of any tag.
     */
    func fetchQuiz(forTag: Tag?, cardOrder: CardOrder, wordCount: Int, callback: @escaping ([WordPair]?, EnfocaError?) -> ()) {
        fatalError()
    }
    
    func updateScore(forWordPair: WordPair, correct: Bool, elapsedTime: Int, callback: @escaping (MetaData?, EnfocaError?) -> ()) {
        fatalError()
    }

    func prepareDataStore(dictionary: UserDictionary?, dataStore: DataStore?, progressObserver: ProgressObserver, callback: @escaping (Bool, EnfocaError?) -> ()) {
        
        callback(true, nil)
    }
    
    func serialize() -> String? {
        return nil
    }

    internal func createTag(fromTag: Tag, callback: @escaping (Tag?, EnfocaError?) -> ()) {
        
        delay(1) {
            let t = Tag(tagId: "eyedee", name: fromTag.name)
            
            print("Dummy create tag \(fromTag.name)")
            
            callback(t, nil)
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

    private var list : [WordPair]
    private var order = WordPairOrder.wordAsc
    
    private static var guidIndex = 0
    
    class func nextIndex() -> Int{
        guidIndex += 1
        return guidIndex
    }
    
    init () {
        
        let tags = DemoWebService.makeTags()
        
        let d = Date()
        list = []
        list.append(DemoWebService.makeWordPairWithTag(word: "blacksmith", definition: "herrero", tags: [tags[0], tags[2]]))
        list.append(WordPair( pairId: "guid\(DemoWebService.nextIndex())", word: "English", definition: "Espanol", dateCreated: d))
        list.append(WordPair(pairId: "guid\(DemoWebService.nextIndex()))", word: "Black", definition: "Negro", dateCreated: d))
//        list.append(DemoWebService.makeWordPairWithTag(word: "Party", definition: "Fiesta", tags: [tags[0]]))
//        list.append(DemoWebService.makeWordPairWithTag(word: "to forge", definition: "forjar", tags: [tags[3], tags[4]]))
//        list.append(WordPair( pairId: "guid\(DemoWebService.nextIndex()))", word: "Tall", definition: "Alta", dateCreated: d))
//        
        
//        list.append(DemoWebService.makeWordPairWithTag(word: "i got to speak with him", definition: "yo conseguí hablar con el", tags: [tags[0], tags[2], tags[3]]))
//        
//        list.append(DemoWebService.makeWordPair( word: "To Run", definition: "Correr"))
//        list.append(DemoWebService.makeWordPair( word: "Clean", definition: "Limpo"))
//        list.append(DemoWebService.makeWordPair( word: "Fat", definition: "Gordo"))
//        list.append(DemoWebService.makeWordPair( word: "To Please", definition: "Gustar"))
//        list.append(DemoWebService.makeWordPair( word: "To Call", definition: "Llamar"))
    }
    
    internal func deactivateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
        if let callback = callback {
            callback(true)
        }
        print("Dummy de-activate called \(wordPair.word)")
    }

    
    internal func activateWordPair(wordPair: WordPair, callback: ((Bool) -> ())?) {
        if let callback = callback {
            callback(true)
        }
        print("Dummy activiate called \(wordPair.word)")
    }
    
    
    internal func fetchWordPairs(tagFilter: [Tag], wordPairOrder: WordPairOrder, pattern: String? = nil, callback: @escaping([WordPair]?,EnfocaError?)->()) {
        
        delay(1) {
            let tagNames : [String] = tagFilter.map { (tag) -> String in
                return tag.name
            }
            
            print("Dummy fetch called with tags \(tagNames)")
            
            if wordPairOrder != self.order {
                self.order = wordPairOrder
                self.list.reverse()
            }
            
            callback(self.list, nil)
        }
    }
    
    
    private class func makeWordPairWithTag(word: String, definition: String, tags : [Tag]) -> WordPair{
        let wp = WordPair( pairId: "1-0-0-1\(nextIndex())", word: word, definition: definition, dateCreated: Date(), tags : tags)
        return wp
    }
    
    private class func makeWordPair(word: String, definition: String) -> WordPair{
        return WordPair( pairId: "1-0-0-1\(nextIndex())", word: word, definition: definition, dateCreated: Date())
    }

    func fetchUserTags(callback : @escaping([Tag]?, EnfocaError?)->()){
        delay(1){
             callback(DemoWebService.makeTags(), nil)
        }
    }
    
    private class func makeTags() -> [Tag] {
        var tags: [Tag] = []
        tags.append(Tag(tagId: "123", name: "Noun"))
        tags.append(Tag(tagId: "124", name: "Verb"))
        tags.append(Tag(tagId: "125", name: "Phrase"))
        tags.append(Tag(tagId: "126", name: "Adverb"))
        tags.append(Tag(tagId: "127", name: "From Class #3"))
        return tags
    }
    
    func createWordPair(word: String, definition: String, tags : [Tag], gender : Gender, example: String? = nil, callback : @escaping(WordPair?, EnfocaError?)->()) {
        
        print("Created \(word) : \(definition) with tags \(tags.tagsToText())")
        let wp = WordPair( pairId: "1-0-0-1\(DemoWebService.nextIndex())", word: word, definition: definition, dateCreated: Date(), gender: gender, tags: tags, example: example)
        callback(wp, nil)
    }
    
    func updateWordPair(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String? = nil, tags : [Tag], callback :
        @escaping(WordPair?, EnfocaError?)->()) {
        
        print("Updated \(word) : \(definition) with tags \(tags.tagsToText())")
        
        let wp = WordPair(pairId: oldWordPair.pairId, word: word, definition: definition, dateCreated: oldWordPair.dateCreated, gender: gender, tags: tags, example: example)
        callback(wp, nil)
    }
    
    private func delay(_ seconds : Int, callback : @escaping ()->()) {
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now() + .seconds(seconds)) {
            callback()
        }
    }
    
    func updateTag(oldTag : Tag, updatedTag: Tag, callback: @escaping(Tag?, EnfocaError?)->()) {
        
    }
    
    func deleteWordPair(wordPair: WordPair, callback: @escaping(WordPair?, EnfocaError?)->()) {}
    
    func deleteTag(tag: Tag, callback: @escaping(Tag?, EnfocaError?)->()){}
    
    func fetchMetaData(forWordPair: WordPair, callback: @escaping (MetaData?, EnfocaError?) -> ()) {
        fatalError()
    }
    
    func initialize(callback: @escaping ([UserDictionary]?, EnfocaError?) -> ()) {
        fatalError()  //Yeah, gonna need to do something about this.
    }
    
    func createDictionary(termTitle: String, definitionTitle: String, subject: String, language: String?, callback: @escaping (UserDictionary?, EnfocaError?) -> ()) {
        fatalError()
    }

    func updateDictionary(oldDictionary : UserDictionary, termTitle: String, definitionTitle: String, subject : String, language: String?, callback :
        @escaping(UserDictionary?, EnfocaError?)->()){
        
        fatalError()
    }
    func getSubject() -> String {
        fatalError()
    }
    
    func getTermTitle() -> String {
        fatalError()
    }
    
    func getDefinitionTitle() -> String {
        fatalError()
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

