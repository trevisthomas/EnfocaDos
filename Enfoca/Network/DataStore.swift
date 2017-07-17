//
//  DataStore.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/24/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class DataStore: NSObject, NSCoding {
    
    private(set) var metaDataDictionary: [String : MetaData] = [:]
    private(set) var tagDictionary : [String : Tag] = [:]
    private(set) var wordPairDictionary : [String :  WordPair] = [:]
    private(set) var tagAssociations : [TagAssociation] = []
    private(set) var isInitialized : Bool = false
    private var userDictionary: UserDictionary!
    
    private var noneTag: Tag!
    private var anyTag: Tag!
    
    func register(anyTag: Tag, noneTag: Tag){
        self.noneTag = noneTag
        self.anyTag = anyTag
        
        updateAnyAndNone()
    }
    
    private func updateAnyAndNone() {
        let wordPairsWithoutTags = wordPairDictionary.values.filter({ (wordPair: WordPair) -> Bool in
            return wordPair.tags.count == 0
        })
        
        self.noneTag.setWordPairs(wordPairs: Array(wordPairsWithoutTags))
        self.anyTag.setWordPairs(wordPairs: Array(wordPairDictionary.values))
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        guard let metaDataDictionary = aDecoder.decodeObject(forKey:"metaDataDictionary") as? [String : MetaData] else {fatalError()}
        guard let tagDictionary = aDecoder.decodeObject(forKey:"tagDictionary") as? [String : Tag] else {fatalError()}
        guard let wordPairDictionary = aDecoder.decodeObject(forKey:"wordPairDictionary") as? [String :  WordPair] else {fatalError()}
       
        guard let tagAssociations = aDecoder.decodeObject(forKey:"tagAssociations") as? [TagAssociation] else {fatalError()}
       
        guard let userDictionary = aDecoder.decodeObject(forKey:"userDictionary") as? UserDictionary else { fatalError() }

        self.init(userDictionary: userDictionary, metaDataDictionary: metaDataDictionary, tagDictionary: tagDictionary, wordPairDictionary: wordPairDictionary, tagAssociations: tagAssociations)
        
    }
    
    init(userDictionary: UserDictionary, metaDataDictionary: [String : MetaData], tagDictionary : [String : Tag], wordPairDictionary : [String :  WordPair], tagAssociations : [TagAssociation]){
        isInitialized = true
        
        self.metaDataDictionary = metaDataDictionary
        self.tagDictionary = tagDictionary
        self.wordPairDictionary = wordPairDictionary
        self.tagAssociations = tagAssociations
        self.userDictionary = userDictionary
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(metaDataDictionary, forKey: "metaDataDictionary")
        aCoder.encode(tagDictionary, forKey: "tagDictionary")
        aCoder.encode(wordPairDictionary, forKey: "wordPairDictionary")
        
        aCoder.encode(tagAssociations, forKey: "tagAssociations")
        aCoder.encode(userDictionary, forKey: "userDictionary")
    }
    
    init(dictionary: UserDictionary) {
        self.userDictionary = dictionary
    }
    
    override init(){
        super.init()
    }
    
    var countAssociations : Int {
        return tagAssociations.count
    }
    
    var countTags : Int {
        return tagDictionary.count
    }
    
    var countWordPairs : Int {
        return wordPairDictionary.count
    }
    
    func getSubject() -> String {
        return userDictionary.subject
    }
    
    func getTermTitle() -> String {
        return userDictionary.termTitle
    }
    
    func getDefinitionTitle() -> String {
        return userDictionary.definitionTitle
    }
    
    func getUserDictionary(refreshCounts: Bool = false) -> UserDictionary {
        if refreshCounts {
            userDictionary.applyCountUpdate(countWordPairs: wordPairDictionary.count, countAssociations: tagAssociations.count, countTags: tagDictionary.count, countMeta: metaDataDictionary.count)
        }
        return userDictionary
    }
    
    func initialize(tags: [Tag], wordPairs: [WordPair], tagAssociations: [TagAssociation], metaData : [MetaData], progressObserver: ProgressObserver? = nil){
        
        let key : String = "DataStoreInit"
        
//        progressObserver?.startProgress(ofType: key, message: "Initializing DataStore")
//        
        self.tagDictionary = tags.reduce([String : Tag]()) { (acc, tag) in
            var dict = acc // This shit show is because the seed dictionary isnt mutable
            dict[tag.tagId] = tag
            return dict
        }
        
//        progressObserver?.updateProgress(ofType: key, message: "DataStore loaded \(tagDictionary.count) tags...")
        
        self.wordPairDictionary = wordPairs.reduce([String : WordPair]()) { (acc, wordPair) in
            var dict = acc
            dict[wordPair.pairId] = wordPair
            return dict
        }
        
//        progressObserver?.updateProgress(ofType: key, message: "DataStore loaded \(wordPairDictionary.count) words...")
        
        self.tagAssociations = tagAssociations
        
        tagAssociations.forEach { (tagAss:TagAssociation) in
            guard let wp = self.wordPairDictionary[tagAss.wordPairId] else {
                fatalError()
            }
            
            guard let t = self.tagDictionary[tagAss.tagId] else {
                fatalError()
            }
            
            t.addWordPair(wp)
            wp.addTag(t)
        }
        
//        progressObserver?.updateProgress(ofType: key, message: "DataStore tagged \(tagAssociations.count) words...")
//        
        self.metaDataDictionary = metaData.reduce([String: MetaData](), { (acc, meta) -> [String: MetaData] in
            var dict = acc
            dict[meta.pairId] = meta
            
//            wordPairDictionary[meta.pairId]?.metaData = meta
            
            return dict
        })
        
//        progressObserver?.updateProgress(ofType: key, message: "Loaded quiz stats for \(metaDataDictionary.count) words...")
//        
        
//        progressObserver?.endProgress(ofType: key, message: "DataStore initialization complete.")
        
        isInitialized = true
    }
    
    func findWordPair(withId wordPairId : String) -> WordPair? {
        return wordPairDictionary[wordPairId]
    }
    
    func remove(tag: Tag, from wordPair: WordPair) -> TagAssociation? {
        guard let tag = tagDictionary[tag.tagId], let wordPair = wordPairDictionary[wordPair.pairId] else {
            fatalError()
        }
        
        guard let index = findAssocationIndex(tagId: tag.tagId, wordPairId: wordPair.pairId) else { fatalError() }
        
        let tagAss = tagAssociations.remove(at: index)
        
        _ = tag.remove(wordPair: wordPair)
        _ = wordPair.remove(tag: tag)
        
        return tagAss
    }
    
    private func findAssocationIndex(tagId: String, wordPairId: String) -> Int? {
        guard let index = (tagAssociations.index { (ass:TagAssociation) -> Bool in
            return ass.tagId == tagId && ass.wordPairId == wordPairId
        }) else {
            return nil
        }
        return index
    }
    
    func add(tag: Tag) {
        tagDictionary[tag.tagId] = tag
    }
    
    func add(wordPair : WordPair) {
        wordPairDictionary[wordPair.pairId] = wordPair
        updateAnyAndNone()
    }
    
    func add(tagAssociation: TagAssociation) {
        guard let tag = tagDictionary[tagAssociation.tagId], let wordPair = wordPairDictionary[tagAssociation.wordPairId] else {
            fatalError()
        }
        
        tag.addWordPair(wordPair)
        wordPair.addTag(tag)
        tagAssociations.append(tagAssociation)
        updateAnyAndNone()
    }
    
    func containsWordPair(withWord: String) -> Bool{
        let matching = wordPairDictionary.values.filter { (wordPair:WordPair) -> Bool in
            return wordPair.word == withWord
        }
        return matching.count > 0
    }
    
    func containsTag(withName: String) -> Bool {
        let matching = tagDictionary.values.filter { (tag:Tag) -> Bool in
            return tag.name == withName
        }
        
        return matching.count > 0
    }
    
    func remove(wordPair: WordPair) -> [TagAssociation] {
        wordPairDictionary.removeValue(forKey: wordPair.pairId)
        var deletedAssociations : [TagAssociation] = []
        tagAssociations = tagAssociations.filter { (tagAss: TagAssociation) -> Bool in
            let keep = tagAss.wordPairId != wordPair.pairId
            if !keep {
                let tag = tagDictionary[tagAss.tagId]
                _ = tag?.remove(wordPair: wordPair)
                
                deletedAssociations.append(tagAss)
            }
            return keep
        }
        updateAnyAndNone()
        return deletedAssociations
    }
    
    func remove(tag: Tag) -> [TagAssociation]{
        tagDictionary.removeValue(forKey: tag.tagId)
        var deletedAssociations : [TagAssociation] = []
        tagAssociations = tagAssociations.filter { (tagAss: TagAssociation) -> Bool in
            let keep = tagAss.tagId != tag.tagId
            if !keep {
                let wp = wordPairDictionary[tagAss.wordPairId]
                _ = wp?.remove(tag: tag)
                deletedAssociations.append(tagAss)
            }
            return keep
        }
        
        updateAnyAndNone()
        return deletedAssociations
    }
    
    //Deprecated i think.  This was created during the weekend of cloudkit subscrption hell
//    func applyUpdate(wordPair: WordPair) {
//        wordPairDictionary[wordPair.pairId]?.applyUpdate(source: wordPair)
//    }
    
    //func reloadTags(callback : @escaping([Tag]?, EnfocaError?)->())
    func reload(updatedTagList: [Tag]) {
        self.tagDictionary.removeAll()
        self.tagDictionary = updatedTagList.reduce([String : Tag]()) { (acc, tag) in
            var dict = acc // This shit show is because the seed dictionary isnt mutable
            dict[tag.tagId] = tag
            return dict
        }
    }
    
    func reload(wordPair: WordPair, withTagAssociations: [TagAssociation], updatedTagList: [Tag]) {
        
        //Replace tag list with updated tag list
        reload(updatedTagList: updatedTagList)
        
        //Remove this word's asses from the ass dict
        tagAssociations = tagAssociations.filter { (tagAss: TagAssociation) -> Bool in
            let keep = tagAss.wordPairId != wordPair.pairId
            return keep
        }
        //remove invalid asses from the ass dict  --- I'm worried that this will be slow so i'm not doing it yet. This means that if a tag is deleted that there could be invalid associations in the list.  Do some tests to figure out if this is an issue, and then decide if you should handle them on a case by case basis or here.
        
        //Add new asses to ass list
        tagAssociations.append(contentsOf: withTagAssociations)
        
        //load tags onto WP object
        wordPair.clearTags()
        for ass in withTagAssociations {
            guard let t = tagDictionary[ass.tagId] else { fatalError() }
            wordPair.addTag(t)
        }
        
        //replace WP object
        wordPairDictionary[wordPair.pairId] = wordPair
    }
    
    func applyUpdate(oldWordPair : WordPair, word: String, definition: String, gender : Gender, example: String?, tags : [Tag]) -> (WordPair, [Tag], [TagAssociation]) {
        
        //Notice that i am creating the new WP with the old tags! This is because the tag changes happen afterward
        let newWordPair = WordPair(pairId: oldWordPair.pairId, word: word, definition: definition, dateCreated: oldWordPair.dateCreated, gender: gender, tags: oldWordPair.tags, example: example)
        
        let oldTags = Set<Tag>(oldWordPair.tags)
        let newTags = Set<Tag>(tags)
        
        let tagsToAdd = newTags.subtracting(oldTags)
        let tagsToRemove = oldTags.subtracting(newTags)
        
        wordPairDictionary[oldWordPair.pairId] = newWordPair
        
        var removedAssociations : [TagAssociation] = []
//        var addedAssociations : [TagAssociation] = []
        //Remove
        for tag in tagsToRemove {
            if let ass = remove(tag: tag, from: newWordPair){
                removedAssociations.append(ass)
            }
        }
//
//        //Add
//        for tag in tagsToAdd {
//            let ass = add(tag: tag, wordPair: newWordPair)
//            addedAssociations.append(ass)
//        }
//        
//        return (newWordPair, addedAssociations, removedAssociations)
        
        
        return (newWordPair, Array(tagsToAdd), removedAssociations)
    }
    
    func applyUpdate(oldTag: Tag, name: String, color: String? = nil) -> Tag{
//        let newTag = Tag(tagId: oldTag.tagId, name: name, color: color)
        oldTag.applyUpdate(name: name, color: color)
        
        let wordPairs = oldTag.wordPairs
        
        var associations : [TagAssociation] = []
        for wp in wordPairs {
            // I'm just using the remove/add methods to update the internal double linking structure with the new object
            // I'm not returning the assocations to the caller because they should be exactly the same
            guard let ass = remove(tag: oldTag, from: wp) else { fatalError() }
            associations.append(ass)
        }
        
//        tagDictionary[oldTag.tagId] = newTag
        
        for ass in associations {
            add(tagAssociation: ass)
        }
        
//        return newTag
        return oldTag
    }
    
    func internalFilterHelper(tags: [Tag]?, pairFilter: ((WordPair) -> Bool)?) -> [WordPair]{
        if let tags = tags, tags.contains(noneTag) {
            //None!
//            return wordPairDictionary.values.filter({ (wordPair: WordPair) -> Bool in
//                return wordPair.tags.count == 0
//            })
            return noneTag.wordPairs
        } else if let tags = tags, tags.contains(anyTag) {
            return anyTag.wordPairs
        } else if let tags = tags, tags.count > 0 {
            
            let tagIds = tags.map({ (tag:Tag) -> AnyHashable in
                return tag.tagId
            })
            
            let filteredAssociations = tagAssociations.filter({ (tagAss:TagAssociation) -> Bool in
                return tagIds.contains(tagAss.tagId)
            })
            
            var wordPairs = Set<WordPair>()
            for ass in filteredAssociations {
                wordPairs.insert(wordPairDictionary[ass.wordPairId]!)
            }
            
            if let pairFilter = pairFilter {
                return wordPairs.filter(pairFilter)
            } else {
                return Array(wordPairs)
            }
        } else {
            if let pairFilter = pairFilter {
                return wordPairDictionary.values.filter(pairFilter)
            } else {
                return Array(wordPairDictionary.values)
            }
        }
    }
    
    private func search(value : String, useWordField: Bool = true, withTags tags : [Tag]? = nil) -> [WordPair]{
        
        let pattern : String
        
        pattern = value

//        pattern = "\\b\(value)"
        
        var pairFilter : ((WordPair) -> Bool)? = nil
        if pattern != "" {
            if useWordField {
                pairFilter = { (wordPair:WordPair) -> Bool in
                    
                    return wordPair.word.range(of: pattern, options: [.regularExpression, .caseInsensitive], range: nil, locale: nil) != nil
    //                return wordPair.word.lowercased().hasPrefix(pattern)
                }
            } else {
                pairFilter = { (wordPair:WordPair) -> Bool in
    //                    return wordPair.definition.lowercased().hasPrefix(pattern)
                    return wordPair.definition.range(of: pattern, options: [.regularExpression, .caseInsensitive], range: nil, locale: nil) != nil
                }
            }
        }
        
        return internalFilterHelper(tags: tags, pairFilter: pairFilter)
        
        //Isn't quiz doing the exact same thing?
//        if let tags = tags, tags.contains(noneTag) {
//            //None!
//            return wordPairDictionary.values.filter({ (wordPair: WordPair) -> Bool in
//                return wordPair.tags.count == 0
//            })
//        } else if let tags = tags, tags.count > 0, !tags.contains(anyTag) {
//            
//            let tagIds = tags.map({ (tag:Tag) -> AnyHashable in
//                return tag.tagId
//            })
//            
//            let filteredAssociations = tagAssociations.filter({ (tagAss:TagAssociation) -> Bool in
//                return tagIds.contains(tagAss.tagId)
//            })
//            
//            var wordPairs = Set<WordPair>()
//            for ass in filteredAssociations {
//                wordPairs.insert(wordPairDictionary[ass.wordPairId]!)
//            }
//            
//            if(pattern == "") {
//                return Array(wordPairs)
//            } else {
//                return wordPairs.filter(pairFilter)
//            }
//        } else {
//            if(pattern == "") {
//                return Array(wordPairDictionary.values)
//            } else {
//                return wordPairDictionary.values.filter(pairFilter)
//            }
//        }
    }
    
    func searchWordsStartWith(phrase: String, order wordPairOrder: WordPairOrder, withTags tagFilter : [Tag]? = nil) -> [WordPair] {
        
        let regex = "\\b\(phrase)"
        
        return search(wordPairMatching : regex, order: wordPairOrder, withTags: tagFilter)
        
    }
    
    func searchExactMatch(phrase: String, order wordPairOrder: WordPairOrder, withTags tagFilter : [Tag]? = nil) -> [WordPair] {
        
        let regex = "^\(phrase.trim())$"
        
        return search(wordPairMatching : regex, order: wordPairOrder, withTags: tagFilter)
    }
    
    func search(forWordsLike : String, withTags tags : [Tag]? = nil) -> [WordPair]{
        return search(value: forWordsLike, useWordField: true, withTags: tags)
    }
   
    func search(wordPairMatching pattern: String, order wordPairOrder: WordPairOrder, withTags tagFilter : [Tag]? = nil) -> [WordPair]{
        
        let wordPairs : [WordPair]
        switch wordPairOrder {
        case .definitionAsc, .definitionDesc:
            wordPairs = search(forDefinitionsLike: pattern, withTags: tagFilter)
        case .wordAsc, .wordDesc:
            wordPairs = search(forWordsLike: pattern, withTags: tagFilter)
        }
        
        var sortFunc : (WordPair, WordPair) -> Bool
        
        switch wordPairOrder {
        case .definitionAsc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.definition.localizedCaseInsensitiveCompare(wp2.definition).rawValue < 0
            }
        case .definitionDesc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.definition.localizedCaseInsensitiveCompare(wp2.definition).rawValue > 0
            }
        case .wordAsc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.word.localizedCaseInsensitiveCompare(wp2.word).rawValue < 0
            }
        case .wordDesc:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                return wp1.word.localizedCaseInsensitiveCompare(wp2.word).rawValue > 0
            }
        }
        
        let sorted = wordPairs.sorted(by: sortFunc)
     
        return sorted
    }
    
    func search(forDefinitionsLike : String, withTags tags : [Tag]? = nil) -> [WordPair]{
        return search(value: forDefinitionsLike, useWordField: false, withTags: tags)
    }
    
    func search(allWithTags: [Tag]) -> [WordPair] {
        return search(value: "", useWordField: false, withTags: allWithTags)
    }
    
    func search(forTagWithName: String) -> [Tag] {
        let pattern = forTagWithName.lowercased()
        return tagDictionary.values.reduce([], { (result:[Tag], tag: Tag) -> [Tag] in
            var accumulator = result
            if tag.name.lowercased().hasPrefix(pattern) {
                accumulator.append(tag)
            }
            return accumulator
        }).sorted(by: { (t1:Tag, t2:Tag) -> Bool in
            t1.name.lowercased() < t2.name.lowercased()
        })
    }
    
    
    func fetchQuiz(cardOrder: CardOrder, wordCount: Int, forTags tags: [Tag]? = nil) -> [WordPair]{
        
        var wordPairs: [WordPair] = internalFilterHelper(tags: tags, pairFilter: nil)
        
//        if let tags = tags, tags.contains(noneTag) {
//            //None!
//            return wordPairDictionary.values.filter({ (wordPair: WordPair) -> Bool in
//                return wordPair.tags.count == 0
//            })
//            
//        } else if let tags = tags, tags.count > 0, !tags.contains(anyTag) {
//            
//            let tagIds = tags.map({ (tag:Tag) -> AnyHashable in
//                return tag.tagId
//            })
//            
//            let filteredAssociations = tagAssociations.filter({ (tagAss:TagAssociation) -> Bool in
//                return tagIds.contains(tagAss.tagId)
//            })
//            
//            var tempPairs = Set<WordPair>()
//            for ass in filteredAssociations {
//                tempPairs.insert(wordPairDictionary[ass.wordPairId]!)
//            }
//            
//            wordPairs = Array(tempPairs)
//            
//        } else {
//            wordPairs = Array(wordPairDictionary.values)
//        }
        
        var sortFunc : ((WordPair, WordPair) -> Bool)?
        
        switch (cardOrder) {
        case .easiest:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                guard let m1 = self.getMetaData(forWordPair: wp1) else {
                    return false //If the meta is null then i cant be easy
                }
                guard let m2 = self.getMetaData(forWordPair: wp2) else {
                    return true
                }
                return m1.score > m2.score
            }
        case .hardest:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                //Trevis, there was a frustrating defect that turned out to be due to the fact that there were meta data's for words that had never been studied.  I modified the score method to just return a zero score in that instance to fix this.  The unit test wasnt catching it.
                guard let m1 = self.getMetaData(forWordPair: wp1) else {
                    return true //If the meta is null then i am assumed hardest
                }
                guard let m2 = self.getMetaData(forWordPair: wp2) else {
                    return false
                }
                
                return m1.score < m2.score
            }
        case .latestAdded:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                guard let m1 = self.getMetaData(forWordPair:wp1) else {
                    return true //If the meta is null, then i must be newer?
                }
                guard let m2 = self.getMetaData(forWordPair:wp2) else {
                    return false
                }
                return m1.dateCreated > m2.dateCreated
            }
        case .leastRecientlyStudied:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                
                //Either the oldest updated date, or null, meaning never
                
                guard let dateUpdated = self.getMetaData(forWordPair:wp1)?.dateUpdated
                    else {
                    return true //If the date is null, then i must have never been studied?
                }
                guard let dateUpdated2 = self.getMetaData(forWordPair:wp2)?.dateUpdated else {
                    return false
                }
                
                return dateUpdated < dateUpdated2
            }
        case .leastStudied:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                guard let m1 = self.getMetaData(forWordPair:wp1) else {
                    return true //If my meta is null, then i have never been studied
                }
                guard let m2 = self.getMetaData(forWordPair:wp2) else {
                    return false
                }
                return m1.timedViewCount < m2.timedViewCount
            }
        case .slowest:
            sortFunc = { (wp1: WordPair, wp2: WordPair) -> Bool in
                guard let m1 = self.getMetaData(forWordPair:wp1) else {
                    return true //If my meta is null, then i have never been studied
                }
                guard let m2 = self.getMetaData(forWordPair:wp2) else {
                    return false
                }
                return m1.averageTime < m2.averageTime
            }
        case .random:
            sortFunc = nil
        }
        
        if let sortFunc = sortFunc {
            wordPairs.sort(by: sortFunc)
        } else {
            //Random
            wordPairs.shuffle()
        }
        
        return Array(wordPairs.prefix(wordCount))
        
    }
    
    //Deprecated
    func updateScore(metaData: MetaData, correct: Bool, elapsedTime: Int) {
        if correct {
            metaData.correct(elapsedTime: elapsedTime)
        } else {
            metaData.incorrect(elapsedTime: elapsedTime)
        }
    }
    
    func add(metaData: MetaData) {
        metaDataDictionary[metaData.pairId] = metaData
    }
    
    func allTags() -> [Tag]{
        return tagDictionary.values.sorted(by: { (t1: Tag, t2: Tag) -> Bool in
            t1.name.lowercased() < t2.name.lowercased()
        })
    }
    
    func getMetaData(forWordPair wordPair: WordPair) -> MetaData? {
        return metaDataDictionary[wordPair.pairId]
    }
    
    //A helper functoin to quickly grab the dictionary out of a json blob.  Created so that i can check the conch before importing the whole thing.
    class func extractDictionary(fromJson json: String) -> UserDictionary {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let rawUserDictionary = jsonResult["userDictionary"] as? String else {fatalError()}
        
        return UserDictionary(json: rawUserDictionary)
    }
    
    convenience init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let rawWordPairs = jsonResult["wordPairs"] as? NSArray else {fatalError()}
        guard let rawTags = jsonResult["tags"] as? NSArray else {fatalError()}
        guard let rawTagAssociations = jsonResult["tagAssociations"] as? NSArray else {fatalError()}
        guard let rawMetaData = jsonResult["metaData"] as? NSArray else {fatalError()}
        guard let rawUserDictionary = jsonResult["userDictionary"] as? String else {fatalError()}
        
        
        var newWordPairs : [WordPair] = []
        for rawWordPair in rawWordPairs {
            guard rawWordPair is String else { fatalError() }
            newWordPairs.append(WordPair(json: rawWordPair as! String))
        }
        
        var newTags : [Tag] = []
        for rawTag in rawTags {
            let json = rawTag as! String
            newTags.append(Tag(json: json))
        }
        
        var newTagAssociations : [TagAssociation] = []
        for rawTagAssociation in rawTagAssociations {
            let json = rawTagAssociation as! String
            newTagAssociations.append(TagAssociation(json: json))
        }
        
        var newMetaData : [MetaData] = []
        for rawMeta in rawMetaData {
            let json = rawMeta as! String
            newMetaData.append(MetaData(json: json))
        }
        
        self.init()
        
        self.userDictionary = UserDictionary(json: rawUserDictionary)
        
        self.initialize(tags: newTags, wordPairs: newWordPairs, tagAssociations: newTagAssociations, metaData: newMetaData)
        
    }
    
    public func toJson() -> String {
        var representation = [String: AnyObject]()
        
        representation["userDictionary"] = userDictionary.toJson() as NSString
        
        representation["wordPairs"] = Array(wordPairDictionary.values).map({ (wp:WordPair) -> AnyObject in
            return wp.toJson() as AnyObject
        }) as AnyObject?
        
        representation["tags"] = Array(tagDictionary.values).map({ (tag:Tag) -> AnyObject in
            return tag.toJson() as AnyObject
        }) as AnyObject?
        
        representation["tagAssociations"] = tagAssociations.map({ (tagAss:TagAssociation) -> AnyObject in
            return tagAss.toJson() as AnyObject
        }) as AnyObject?
        
        representation["metaData"] = Array(metaDataDictionary.values).map({ (meta:MetaData) -> AnyObject in
            return meta.toJson() as AnyObject
        }) as AnyObject?
        
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
}
