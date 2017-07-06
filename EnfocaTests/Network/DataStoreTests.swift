//
//  DataStoreTests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/24/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class DataStoreTests: XCTestCase {
    var sut : DataStore!
    
    var tags : [Tag] = []
    var wordPairs : [WordPair] = []
    var wpAss : [TagAssociation] = []
    var metaDataList : [MetaData] = []
    
    var dictionary: UserDictionary!
    
    override func setUp() {
        super.setUp()
        
        dictionary = UserDictionary(termTitle: "English", definitionTitle: "Spanish", subject: "My ly-berry")
        
        sut = DataStore(dictionary: dictionary)
        sut.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss, metaData: metaDataList)
    }
    
    func testInit(){
        mockDataOne()
        
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        XCTAssertTrue(sut.isInitialized)
    }
    
    func testInit_PairShouldHaveExpectedTags(){
        mockDataOne()
        
        guard let wp : WordPair = sut.findWordPair(withId: "100") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(wp.tags.count, 2)
        XCTAssertEqual(wp.tags.tagsToText(), "Adjective, Noun")
    }
    
    func testTagAssociation_AddTagShouldWork() {
        mockDataOne()
        
        let tag = sut.tagDictionary["1"]!
        let wordPair = sut.wordPairDictionary["102"]!
        
        XCTAssertEqual(tag.count, 2) //Initial state
        
        
        let newAssociation = TagAssociation(associationId: "14", wordPairId: wordPair.pairId, tagId: tag.tagId)
        
        sut.add(tagAssociation: newAssociation)
        
        XCTAssertEqual(tag.count, 3)
        XCTAssertTrue(tag.wordPairs.contains(wordPair))
        XCTAssertTrue(wordPair.tags.contains(tag))
        XCTAssertTrue(sut.tagAssociations.contains(where: { (tagAss : TagAssociation) -> Bool in
            return tagAss.tagId == tag.tagId && tagAss.wordPairId == wordPair.pairId
        }))
        
        XCTAssertEqual(newAssociation.tagId, tag.tagId)
        XCTAssertEqual(newAssociation.wordPairId, wordPair.pairId)
    }
    
    func testTagAssociation_RemoveTagShouldWork(){
        mockDataOne()
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        let tag = sut.tagDictionary["1"]!
        let wordPair = sut.wordPairDictionary["100"]!
        
        XCTAssertEqual(wordPair.tags.count, 2) //initial state
        XCTAssertEqual(tag.count, 2) //Initial state
        XCTAssertTrue(wordPair.tags.contains(tag)) //Initial
        
        guard let tagAssociation = sut.remove(tag: tag, from: wordPair) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(tagAssociation.tagId, tag.tagId)
        XCTAssertEqual(tagAssociation.wordPairId, wordPair.pairId)
        
        XCTAssertFalse(tag.wordPairs.contains(wordPair))
        XCTAssertFalse(wordPair.tags.contains(tag))
        XCTAssertEqual(tag.count, 1)
        XCTAssertEqual(wordPair.tags.count, 1)
        
        XCTAssertEqual(wpAss.count - 1, sut.countAssociations)
        //Removing the association should *not* remove the tag or the wordPair!
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
    }
    
    func testWordPair_CreateShouldCreate(){
        mockDataOne()
        
        let word = "Pegajosa"
        let definition = "Sticky"
        let gender : Gender = .masculine
        let example = "La mesa es pegajosa."
        let date = Date()
        let wpId = "Eye Dee"
        
        let wp = WordPair(pairId: wpId, word: word, definition: definition, dateCreated: date, gender: gender, tags: [], example: example);
        
        _ = sut.add(wordPair: wp);
        
        let wp2 = sut.findWordPair(withId: wpId)!;
        
        XCTAssertEqual(wp.word, wp2.word)
        XCTAssertEqual(wp.definition, wp2.definition)
        XCTAssertEqual(wp.dateCreated, wp2.dateCreated)
        XCTAssertEqual(wp.example, wp2.example)
        XCTAssertEqual(wp.gender, wp2.gender)
        XCTAssertEqual(wp.tags, wp2.tags)
    }
    
    func testWordPair_existsShouldVerifyExistance(){
        mockDataOne()
        
        XCTAssertTrue(sut.containsWordPair(withWord: "Azul"))
        XCTAssertFalse(sut.containsWordPair(withWord: "llave"))
    }
    
    func testTag_containsTagShouldWork() {
        mockDataOne()
        
        XCTAssertTrue(sut.containsTag(withName: "Noun"))
        XCTAssertFalse(sut.containsTag(withName: "Jack"))
        
    }
    
    func testWordPair_DeleteShouldDelete(){
        mockDataOne()
        
        let tag1 = sut.tagDictionary["1"]
        let tag3 = sut.tagDictionary["3"]
        
        XCTAssertEqual(tag1?.count, 2)
        XCTAssertEqual(tag3?.count, 1)
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        let wp = sut.wordPairDictionary["100"]!
        
        let associations = sut.remove(wordPair: wp)
        
        XCTAssertEqual(associations.count, 2)
        
        XCTAssertEqual(wpAss.count - 2, sut.countAssociations)
        XCTAssertEqual(wordPairs.count - 1, sut.countWordPairs)
        XCTAssertEqual(tag1?.count, 1)
        XCTAssertEqual(tag3?.count, 0)
        
    }
    
    func testTag_RemoveShouldRemove(){
        mockDataOne()
        let tag = sut.tagDictionary["1"]!
        
        XCTAssertEqual(tag.count, 2)
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        let pairsWithTag = tag.wordPairs
        
        for wp in pairsWithTag {
            XCTAssertTrue(wp.tags.contains(tag))
        }
        
        
        let removed = sut.remove(tag: tag)
        
        XCTAssertEqual(removed.count, 2)
        
        for wp in pairsWithTag {
            XCTAssertFalse(wp.tags.contains(tag))
        }
        
        XCTAssertEqual(wpAss.count - 2, sut.countAssociations)
        XCTAssertEqual(tags.count - 1, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
    }
    
    func testWordPair_ModifyShouldModify(){
        mockDataOne()
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        let wp = sut.wordPairDictionary["100"]!
        
        
        _ = sut.applyUpdate(oldWordPair: wp, word: "Nuevo", definition: "New", gender: .feminine, example: "Example", tags: wp.tags)
        
        let updatedWp = sut.wordPairDictionary[wp.pairId]
        XCTAssertEqual(updatedWp?.word, "Nuevo")
        XCTAssertEqual(updatedWp?.definition, "New")
        XCTAssertEqual(updatedWp?.gender, .feminine)
        XCTAssertEqual(updatedWp?.example, "Example")
        XCTAssertEqual((updatedWp?.tags)!, wp.tags)
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
    }
    
    func testWordPair_ModifyToRemoveTagShouldRemove(){
        mockDataOne()
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        let wp = sut.wordPairDictionary["100"]!
        
        XCTAssertEqual(wp.tags.count, 2)
        
        var newTags = wp.tags
        let removedTag = newTags.remove(at: 0)
        
        XCTAssertEqual(wp.tags.count, 2) //Asserting that mutating the newTags varible doesnt impact the tags attribute that it was copied from.
        
        let tuple = sut.applyUpdate(oldWordPair: wp, word: wp.word, definition: wp.definition, gender: wp.gender, example: wp.example, tags: newTags)
        
        XCTAssertEqual(wpAss.count - 1, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        
        XCTAssertEqual(tuple.0.tags.count, 1)
        XCTAssertFalse(tuple.0.tags.contains(removedTag))
        XCTAssertTrue(tuple.0.tags.contains(wp.tags[1]))
        
        
        XCTAssertEqual(tuple.1.count, 0)
        XCTAssertEqual(tuple.2.count, 1) // Remove one tag
        
        //Confirming that the removed association list has the removed tag
        XCTAssertEqual(removedTag.tagId, tuple.2[0].tagId)
        
    }
    
    func testWordPair_ModifyToAddTagShouldAdd(){
        mockDataOne()
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        let wp = sut.wordPairDictionary["100"]!
        
        XCTAssertEqual(wp.tags.count, 2)
        
        let tagAdded = sut.tagDictionary["2"]!
        
        var newTags = wp.tags
        newTags.append(tagAdded)
        
        
        XCTAssertEqual(wp.tags.count, 2)
        
        let tuple = sut.applyUpdate(oldWordPair: wp, word: wp.word, definition: wp.definition, gender: wp.gender, example: wp.example, tags: newTags)
        
        var i = 0
        for tag in tuple.1 {
            i = i+1
            let association = TagAssociation(associationId: "new\(i)", wordPairId: wp.pairId, tagId: tag.tagId)
            sut.add(tagAssociation: association)
        }
        
        XCTAssertEqual(wpAss.count + 1, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
        
        
        XCTAssertEqual(tuple.0.tags.count, 3)
        XCTAssertTrue(tuple.0.tags.contains(tagAdded))
        
        
        XCTAssertEqual(tuple.1.count, 1) // added one tag association
        XCTAssertEqual(tuple.2.count, 0) // Remove one tag
        
        //Confirming that the added association list has the added tag
        XCTAssertEqual(tagAdded.tagId, tuple.1[0].tagId)
        
    }
    
    func testTag_Modify(){
        mockDataOne()
        
        let wp = sut.wordPairDictionary["100"]!
        let tag = wp.tags[0]
        
        XCTAssertEqual(wp.tags.count, 2) //Initial state
        XCTAssertEqual(tag.count, 1) //Initial state
        
        let newTag = sut.applyUpdate(oldTag: tag, name: "Fuzzy")
        
        
        XCTAssertEqual(newTag.tagId, tag.tagId)
        XCTAssertEqual(newTag.name, "Fuzzy")
        
        //Hm.
        
        let wp2 = sut.wordPairDictionary["100"]!
        
        XCTAssertEqual(wp2.tags.count, 2) //No change
        XCTAssertEqual(newTag.count, 1) //No change
        XCTAssertTrue(wp2.tags.contains(newTag))
        
        
        XCTAssertEqual(wpAss.count, sut.countAssociations)
        XCTAssertEqual(tags.count, sut.countTags)
        XCTAssertEqual(wordPairs.count, sut.countWordPairs)
    }

    func testSearch_ByWord(){
        mockDataOne()
        
        var result = sut.search(forWordsLike : "\\ba")
        
        XCTAssertEqual(result.count, 2)
        
        result = sut.search(forWordsLike : "\\bA")
        
        XCTAssertEqual(result.count, 2)
    }
    
    func testSearchStartsWith_ShouldMatch() {
        mockDataOne()
        
        sut.add(wordPair: WordPair(pairId: "--1--1", word: "nice phrase", definition: "pero en espanol"))
        
        var result = sut.searchWordsStartWith(phrase: "a", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 2)
        
        result = sut.searchWordsStartWith(phrase: "A", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 2)

        result = sut.searchWordsStartWith(phrase: "phrase", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 1)
    }
    
    func testSearchExact_ShouldMatch() {
        mockDataOne()
        
        sut.add(wordPair: WordPair(pairId: "--1--1", word: "nice phrase", definition: "pero en espanol"))
        
        var result = sut.searchExactMatch(phrase: "a", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 0)
        
        result = sut.searchExactMatch(phrase: "A", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 0)
        
        result = sut.searchExactMatch(phrase: "nice", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 0)
        
        result = sut.searchExactMatch(phrase: "nice phrase", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 1)
        
        result = sut.searchExactMatch(phrase: " nice phrase ", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result.count, 1)
    }
    
    
    func testSearch_WordContains(){
        mockDataOne()
        
        _ = sut.add(wordPair: WordPair(pairId: "4", word: "en casa", definition: "at home"))
        
        let result = sut.search(forWordsLike : "casa")
        
        XCTAssertEqual(result.count, 1)
        
        
    }
    
    func testSearch_ByDefinition(){
        mockDataOne()
        
        let result = sut.search(forDefinitionsLike : "bl")
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].word, "Azul")
    }
    
    func testSearch_ByWordWithTag(){
        mockDataOne()
        
        let tag = sut.tagDictionary["3"]!
        let result = sut.search(forWordsLike : "a", withTags: [tag])
        
        XCTAssertEqual(result.count, 1)
        
        XCTAssertEqual(result[0].word, "Azul")
    }
    
    func testSearch_ByTag(){
        mockDataOne()
        
        let tag = sut.tagDictionary["1"]!
        let result = sut.search(forWordsLike : "", withTags: [tag])
        
        XCTAssertEqual(result.count, 2)
        
    }
    
    func testSearch_ByDefinitionWithTag(){
        mockDataOne()
        let tag = sut.tagDictionary["1"]!
        let result = sut.search(forDefinitionsLike : "b", withTags: [tag])
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].word, "Azul")
    }
    
    func testSearch_AllWithTags(){
        mockDataOne()
        
        let tag = sut.tagDictionary["1"]!
        let tag2 = sut.tagDictionary["3"]!
        
        let result = sut.search(allWithTags: [tag, tag2])
        XCTAssertEqual(result.count, 2)
    }
    
    func testSearch_TagsByNameShouldFindTag() {
        mockDataOne()
        
        let result = sut.search(forTagWithName: "nOu")
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "Noun")
    }
    
    func testSearch_ForWordPairWithOrderAscByDef() {
        mockDataOne()
        
        let result = sut.search(wordPairMatching: "", order: .definitionAsc, withTags: nil)
        
        XCTAssertEqual(result[0].definition, "Blue")
        XCTAssertEqual(result[1].definition, "Nail")
        XCTAssertEqual(result[2].definition, "Yellow")
    }
    
    func testSearch_ForWordPairWithOrderDescByDef() {
        mockDataOne()
        
        let result = sut.search(wordPairMatching: "", order: .definitionDesc, withTags: nil)
        
        XCTAssertEqual(result[0].definition, "Yellow")
        XCTAssertEqual(result[1].definition, "Nail")
        XCTAssertEqual(result[2].definition, "Blue")
    }
    
    func testSearch_ForWordPairWithOrderAscByWord() {
        mockDataOne()
        
        let result = sut.search(wordPairMatching: "", order: .wordAsc, withTags: nil)
        
        XCTAssertEqual(result[0].word, "Amarillo")
        XCTAssertEqual(result[1].word, "Azul")
        XCTAssertEqual(result[2].word, "Clave")
    }
    
    func testSearch_ForWordPairWithOrderDescByWord() {
        mockDataOne()
        
        let result = sut.search(wordPairMatching: "", order: .wordDesc, withTags: nil)
        
        XCTAssertEqual(result[0].word, "Clave")
        XCTAssertEqual(result[1].word, "Azul")
        XCTAssertEqual(result[2].word, "Amarillo")
    }
    
    func testSearch_ForWordPairWithOrderAscByWordWithTag() {
        mockDataOne()
        
        let tag = sut.tagDictionary["1"]!
        
        let result = sut.search(wordPairMatching: "", order: .wordAsc, withTags: [tag])
        
        XCTAssertEqual(result[0].word, "Amarillo")
        XCTAssertEqual(result[1].word, "Azul")
        XCTAssertEqual(result.count, 2)
    }
    
    func testSearch_ForWordPairWithOrderAscByDefWithTagAndPhrase() {
        mockDataOne()
        
        let tag = sut.tagDictionary["1"]!
        
        let result = sut.search(wordPairMatching: "Bl", order: .definitionAsc, withTags: [tag])
        
        XCTAssertEqual(result[0].word, "Azul")
        XCTAssertEqual(result.count, 1)
    }

    func testSearch_SearchForNothingShouldFindAll() {
        mockDataOne()
        
        let result = sut.search(wordPairMatching: "", order: .definitionAsc, withTags: nil)
        
        
        XCTAssertEqual(result.count, 3)
    }
    
    func testSearch_SearchForBlankPhraseWithTagShouldFindTagged() {
        mockDataOne()
        let tag = sut.tagDictionary["1"]!
        
        let result = sut.search(wordPairMatching: "", order: .definitionAsc, withTags: [tag])
        
        
        XCTAssertEqual(result.count, 2)
    }
    
    func testSearch_SearchForNothingShouldFindAllTwo() {
        mockDataOne()
        
        let result = sut.search(wordPairMatching: "", order: .definitionAsc, withTags: [])
        
        
        XCTAssertEqual(result.count, 3)
    }
    
    func testQuiz_EasiestShouldBeEasy(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .easiest, wordCount: 3)
        
        XCTAssertTrue(sut.getMetaData(forWordPair: result[0])!.score > sut.getMetaData(forWordPair: result[1])!.score)
        XCTAssertTrue(sut.getMetaData(forWordPair: result[1])!.score > sut.getMetaData(forWordPair: result[2])!.score)
        
    }
    
    func testQuiz_EasiestShouldBeEasyNil(){
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .easiest, wordCount: 3)
        
        XCTAssertEqual(result[0], wordPairs[1])
        XCTAssertEqual(result[1], wordPairs[0])
        XCTAssertEqual(result[2], wordPairs[2])
        
    }
    
    func testQuiz_HardestShouldBeHard(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .hardest, wordCount: 3)
        
        XCTAssertTrue(sut.getMetaData(forWordPair: result[0])!.score < sut.getMetaData(forWordPair: result[1])!.score)
        XCTAssertTrue(sut.getMetaData(forWordPair: result[1])!.score < sut.getMetaData(forWordPair: result[2])!.score)
        
    }
    
    func testQuiz_HardestShouldBeHardNil(){
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .hardest, wordCount: 3)
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[0])
        XCTAssertEqual(result[2], wordPairs[1])
        
    }
    
    func testQuiz_HardestShouldUnTested(){
        mockDataThree_UnscoredMeta()
        
        let result = sut.fetchQuiz(cardOrder: .hardest, wordCount: 3)
        
        XCTAssertEqual(result[0], wordPairs[1])
        XCTAssertEqual(result[1], wordPairs[0])
        XCTAssertEqual(result[2], wordPairs[2])
        
        
    }
    
    func testQuiz_LatestShouldBeLater(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .latestAdded, wordCount: 3)
        
        XCTAssertTrue(sut.getMetaData(forWordPair: result[0])!.score > sut.getMetaData(forWordPair: result[1])!.score)
        XCTAssertTrue(sut.getMetaData(forWordPair: result[1])!.score > sut.getMetaData(forWordPair: result[2])!.score)
        
    }
    
    func testQuiz_LatestShouldBeLaterWithNil(){
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .latestAdded, wordCount: 3)
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[1])
        XCTAssertEqual(result[2], wordPairs[0])
        
        
    }
    
    func testQuiz_LeastRecientlyStudied(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .leastRecientlyStudied, wordCount: 3)
        
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[1])
        XCTAssertEqual(result[2], wordPairs[0])
        
    }
    
    func testQuiz_LeastRecientlyStudiedWithNil(){
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .leastRecientlyStudied, wordCount: 3)
        
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[1])
        XCTAssertEqual(result[2], wordPairs[0])
        
    }
    
    func testQuiz_LeastOftenStudied(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .leastStudied, wordCount: 3)
        
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[0])
        XCTAssertEqual(result[2], wordPairs[1])
        
    }
    
    func testQuiz_LeastOftenStudiedWithNil(){
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .leastStudied, wordCount: 3)
        
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[0])
        XCTAssertEqual(result[2], wordPairs[1])
        
    }


    func testQuiz_SlowestResponses(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .slowest, wordCount: 3)
        
        
        XCTAssertEqual(result[0], wordPairs[0])
        XCTAssertEqual(result[1], wordPairs[2])
        XCTAssertEqual(result[2], wordPairs[1])
        
    }
    
    func testQuiz_SlowestResponsesWithNilMeta(){
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .slowest, wordCount: 3)
        
        
        XCTAssertEqual(result[0], wordPairs[2])
        XCTAssertEqual(result[1], wordPairs[0])
        XCTAssertEqual(result[2], wordPairs[1])
        
    }
    
    
    func testQuiz_Random(){
        mockDataOne()
        
        let result = sut.fetchQuiz(cardOrder: .random, wordCount: 3)
        var resultAlt = sut.fetchQuiz(cardOrder: .random, wordCount: 3)
        
        
        for _ in 0...10 {
            if result != resultAlt {
                return //They didnt match.  This is what i want.
            } else {
                //If they matched, try again.
                resultAlt = sut.fetchQuiz(cardOrder: .random, wordCount: 3)
            }
        }
        
        //If we get here, after 10 tries all were the same, then random isnt working.  Even with this small set
        
        assertionFailure("Failed to mutate.  Random isn't working.")
        
    }
    
    func testQuizScore_ShouldUpdate() {
        mockDataTwo_SomeNilMeta()
        
        let result = sut.fetchQuiz(cardOrder: .easiest, wordCount: 1, forTags: [tags[1]])
        
        XCTAssertEqual(result.count, 1)
        
        XCTAssertEqual(result[0].word, "Clave")
        
        XCTAssertNil(sut.getMetaData(forWordPair: result[0]))
        
        let metaData = MetaData(metaId: "mock", pairId: result[0].pairId, dateCreated: Date(), dateUpdated: nil, incorrectCount: 0, totalTime: 0, timedViewCount: 0)
        
        sut.updateScore(metaData: metaData, correct: true, elapsedTime: 10)
        
        XCTAssertEqual(metaData.totalTime, 10)
        sut.add(metaData: metaData)
        
        let meta = sut.getMetaData(forWordPair: result[0])
        
        XCTAssertEqual(meta?.timedViewCount, 1)
        XCTAssertEqual(meta?.scoreAsString, "100%")
        
        let result2 = sut.fetchQuiz(cardOrder: .easiest, wordCount: 1, forTags: [tags[1]])
        
        let meta2 = sut.getMetaData(forWordPair: result2[0])
        
        sut.updateScore(metaData: meta2!, correct: false, elapsedTime: 20)
        
        XCTAssertEqual(metaData.totalTime, 30)
        
        XCTAssertEqual(meta?.timedViewCount, 2)
        XCTAssertEqual(meta?.scoreAsString, "50%")
        
        
    }
    
    func testReload_ReloadedWordAndItsTagsAndItsAssesShouldBeGood() {
        mockDataOne()
        
        //Asserting the initial state
        let origWp = sut.findWordPair(withId: "100")!
        XCTAssertEqual(origWp.tags.count, 2)
        XCTAssertEqual(origWp.tags.tagsToText(), "Adjective, Noun")
        
        
        //Make a new tag and change the values of the wp
        
        let updatedWP = WordPair(pairId: "100", word: "Azul-changed", definition: "Blue")
        
        let newTag = Tag(tagId: "4", name: "NewTag")
        let newAss = TagAssociation(associationId: "13", wordPairId: updatedWP.pairId, tagId: newTag.tagId)
        
        tags.append(newTag)
        
        var updatedAsses : [TagAssociation] = []
        for ass in wpAss {
            if ass.wordPairId == updatedWP.pairId {
                updatedAsses.append(ass)
            }
        }
        
        updatedAsses.append(newAss)
        
        sut.reload(wordPair: updatedWP, withTagAssociations: updatedAsses, updatedTagList: tags)
        
        guard let wp : WordPair = sut.findWordPair(withId: "100") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(wp.tags.count, 3)
        XCTAssertEqual(wp.tags.tagsToText(), "Adjective, NewTag, Noun")
    }
    
   
    func testReload_TagShouldBeChangedOnAllTaggedWords() {
        mockDataOne()
        
        //Asserting the initial state
        let origWp = sut.findWordPair(withId: "100")!
        XCTAssertEqual(origWp.tags.count, 2)
        XCTAssertEqual(origWp.tags.tagsToText(), "Adjective, Noun")
        
        
        //Make a new tag and change the values of the wp
        
        let updatedWP = origWp //Not even bothering to change the word.
        
        let newTag = Tag(tagId: "1", name: "NewNoun")
//        let newAss = TagAssociation(associationId: "13", wordPairId: updatedWP.pairId, tagId: newTag.tagId)
//        
        XCTAssertEqual(tags[0].tagId, "1") //Just making sure that the first tag in the list is the one that i am changing
        tags.remove(at: 0)
        tags.append(newTag)
        
        var updatedAsses : [TagAssociation] = []
        for ass in wpAss {
            if ass.wordPairId == updatedWP.pairId {
                updatedAsses.append(ass)
            }
        }
        
//        updatedAsses.append(newAss)
        
        sut.reload(wordPair: updatedWP, withTagAssociations: updatedAsses, updatedTagList: tags)
        
        guard let wp : WordPair = sut.findWordPair(withId: "100") else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(wp.tags.count, 2) //Tag count should still be two
        XCTAssertEqual(wp.tags.tagsToText(), "Adjective, NewNoun")
        
        // NOTE!  The tag is updated in the tags list, but not on every word that contains the tag.  The other words still have the old tag.
        //XCTAssertEqual(wordPairs[1].tags.tagsToText(), "NewNoun")
    }
    
    func testDataStoreCounts(){
        mockDataOne()
        
        let dict = sut.getUserDictionary(refreshCounts: true)
        
        XCTAssertEqual(dict.countWordPairs, 3)
        XCTAssertEqual(dict.countAssociations, 3)
        XCTAssertEqual(dict.countTags, 3)
        XCTAssertEqual(dict.countMeta, 3)
    }

}


extension DataStoreTests{
    func mockDataOne(){
        tags.append(Tag(tagId: "1", name: "Noun"))
        tags.append(Tag(tagId: "2", name: "Verb"))
        tags.append(Tag(tagId: "3", name: "Adjective"))
        
        wordPairs.append(WordPair(pairId: "100", word: "Azul", definition: "Blue"))
        wordPairs.append(WordPair(pairId: "101", word: "Amarillo", definition: "Yellow"))
        wordPairs.append(WordPair(pairId: "102", word: "Clave", definition: "Nail"))
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
//        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let lastWeekPlus1 = Calendar.current.date(byAdding: .day, value: 1, to: lastWeek)!
        let lastWeekPlus2 = Calendar.current.date(byAdding: .day, value: 2, to: lastWeek)!
        
        metaDataList.append(MetaData(metaId: "1010", pairId: wordPairs[0].pairId, dateCreated: lastWeek, dateUpdated: today, incorrectCount: 10, totalTime: 10, timedViewCount: 10))
        
        metaDataList.append(MetaData(metaId: "1011", pairId: wordPairs[1].pairId, dateCreated: lastWeekPlus2, dateUpdated: yesterday, incorrectCount: 0, totalTime: 100, timedViewCount: 11))
        
        metaDataList.append(MetaData(metaId: "1012", pairId: wordPairs[2].pairId, dateCreated: lastWeekPlus1, dateUpdated: nil, incorrectCount: 5, totalTime: 50, timedViewCount: 9))
        
        
        wpAss.append(TagAssociation(associationId: "10", wordPairId: wordPairs[0].pairId, tagId: tags[0].tagId))
        
        wpAss.append(TagAssociation(associationId: "11", wordPairId: wordPairs[0].pairId, tagId: tags[2].tagId))
        
        wpAss.append(TagAssociation(associationId: "12", wordPairId: wordPairs[1].pairId, tagId: tags[0].tagId))
        
        
        sut.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss, metaData: metaDataList)
    }
    
    func mockDataTwo_SomeNilMeta(){
        tags.append(Tag(tagId: "1", name: "Noun"))
        tags.append(Tag(tagId: "2", name: "Verb"))
        tags.append(Tag(tagId: "3", name: "Adjective"))
        
        wordPairs.append(WordPair(pairId: "100", word: "Azul", definition: "Blue"))
        wordPairs.append(WordPair(pairId: "101", word: "Amarillo", definition: "Yellow"))
        wordPairs.append(WordPair(pairId: "102", word: "Clave", definition: "Nail"))
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let lastWeekPlus1 = Calendar.current.date(byAdding: .day, value: 1, to: lastWeek)!
        
        metaDataList.append(MetaData(metaId: "1010", pairId: wordPairs[0].pairId, dateCreated: lastWeek, dateUpdated: today, incorrectCount: 10, totalTime: 10, timedViewCount: 10))
        
        metaDataList.append(MetaData(metaId: "1011", pairId: wordPairs[1].pairId, dateCreated: lastWeekPlus1, dateUpdated: yesterday, incorrectCount: 0, totalTime: 100, timedViewCount: 11))
        
        wpAss.append(TagAssociation(associationId: "10", wordPairId: wordPairs[0].pairId, tagId: tags[0].tagId))
        
        wpAss.append(TagAssociation(associationId: "11", wordPairId: wordPairs[0].pairId, tagId: tags[2].tagId))
        
        wpAss.append(TagAssociation(associationId: "12", wordPairId: wordPairs[1].pairId, tagId: tags[0].tagId))
        
        wpAss.append(TagAssociation(associationId: "13", wordPairId: wordPairs[2].pairId, tagId: tags[1].tagId))
        
        
        sut.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss, metaData: metaDataList)
    }

    func mockDataThree_UnscoredMeta(){
        tags.append(Tag(tagId: "1", name: "Noun"))
        tags.append(Tag(tagId: "2", name: "Verb"))
        tags.append(Tag(tagId: "3", name: "Adjective"))
        
        wordPairs.append(WordPair(pairId: "100", word: "Azul", definition: "Blue"))
        wordPairs.append(WordPair(pairId: "101", word: "Amarillo", definition: "Yellow"))
        wordPairs.append(WordPair(pairId: "102", word: "Clave", definition: "Nail"))
        
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        //        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        
        let lastWeek = Calendar.current.date(byAdding: .day, value: -7, to: today)!
        let lastWeekPlus1 = Calendar.current.date(byAdding: .day, value: 1, to: lastWeek)!
        let lastWeekPlus2 = Calendar.current.date(byAdding: .day, value: 2, to: lastWeek)!
        
        metaDataList.append(MetaData(metaId: "1010", pairId: wordPairs[0].pairId, dateCreated: lastWeek, dateUpdated: today, incorrectCount: 4, totalTime: 10, timedViewCount: 10))
        
        metaDataList.append(MetaData(metaId: "1011", pairId: wordPairs[1].pairId, dateCreated: lastWeekPlus2, dateUpdated: nil, incorrectCount: 0, totalTime: 0, timedViewCount: 0))
        
        metaDataList.append(MetaData(metaId: "1012", pairId: wordPairs[2].pairId, dateCreated: lastWeekPlus1, dateUpdated: yesterday, incorrectCount: 1, totalTime: 50, timedViewCount: 10))
        
        
        wpAss.append(TagAssociation(associationId: "10", wordPairId: wordPairs[0].pairId, tagId: tags[0].tagId))
        
        wpAss.append(TagAssociation(associationId: "11", wordPairId: wordPairs[0].pairId, tagId: tags[2].tagId))
        
        wpAss.append(TagAssociation(associationId: "12", wordPairId: wordPairs[1].pairId, tagId: tags[0].tagId))
        
        
        sut.initialize(tags: tags, wordPairs: wordPairs, tagAssociations: wpAss, metaData: metaDataList)
    }

    
}


