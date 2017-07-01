//
//  Import.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import UIKit
import CloudKit

class Import {
    
    var tagDict : [String: OldTag] = [:]
    var wordPairDict : [String: OldWordPair] = [:]
    var metaDict: [String: OldMetaData] = [:]
    var tagAssociations : [OldTagAssociation] = []
    let dateformatter = DateFormatter()
    let enfocaId : NSNumber!
    let enfocaRef: CKReference!
    
    
//    let metaResource = "study_item_meta"
//    let tagResource = "tag"
//    let studyItemResource = "study_item"
//    let tagAssociationResource = "tag_associations"
    
    let metaResource = "small_study_item_meta"
    let tagResource = "small_tag"
    let studyItemResource = "small_study_item"
    let tagAssociationResource = "small_tag_associations"
    
    
    //DEPRECATED!
    init(enfocaId id: Int){
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        enfocaId = NSNumber(value: id)
        enfocaRef = nil
    }
    
    init(enfocaRef: String) {
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        enfocaId = nil
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: enfocaRef)
        self.enfocaRef = CKReference(recordID: recordId, action: .none)
    }
    
    func process(){
        loadMeta()
        loadWordPairs()
        loadTags()
        loadTagAssociations()
        print("Saving to cloud kit")
        saveDataToCloudKit()
    }
    
    func loadMeta(){
        guard let path = Bundle.main.path(forResource: metaResource, ofType: "json") else { fatalError() }
//        guard let path = Bundle.main.path(forResource: "test", ofType: "json") else { fatalError() }
        guard let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data  else { fatalError() }
        guard let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray else { fatalError() }
        
        for raw in jsonResult{
            let meta = raw as! NSDictionary
            
            guard let id = meta["studyItemId"] as? String else {fatalError()}
            guard let createDateString = meta["createDate"] as? String else {fatalError()}
            guard let createDate  = dateformatter.date(from: createDateString) else {fatalError()}
            guard let incorrectCount = meta["incorrectCount"] as? Int else {fatalError()}
            var lastUpdateDate : Date?
            if let lastUpdateString = meta["lastUpdate"] as? String {
                guard let lastUpdate  = dateformatter.date(from: lastUpdateString) else {fatalError()}
                lastUpdateDate = lastUpdate
            }
            
            guard let totalTime = meta["totalTime"] as? Int else {fatalError()}
            guard let timedViewCount = meta["timedViewCount"] as? Int else {fatalError()}
            
            let oldMeta = OldMetaData(studyItemId: id, creationDate: createDate, incorrectCount: incorrectCount, lastUpdate: lastUpdateDate, totalTime: totalTime, timedViewCount: timedViewCount)
            
            metaDict[id] = oldMeta
            
        }
        print("Loaded \(metaDict.count) meta data rows.")
        
    }

    
    func loadTags(){
        if let path = Bundle.main.path(forResource: tagResource, ofType: "json") {
            if let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data{
                if let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray {
                    
                    for raw in jsonResult{
                        let tag = raw as! NSDictionary
                        
                        guard let id = tag["tagId"] as? String else {fatalError()}
                        guard let name = tag["tagName"] as? String else {fatalError()}
                        let oldTag = OldTag(tagId: id, tagName: name)
                        
                        tagDict[oldTag.tagId] = oldTag
                        
                    }
                }
            }
        }
        print("Loaded \(tagDict.count) tags.")
    }
    
    func loadWordPairs(){
        guard let path = Bundle.main.path(forResource: studyItemResource, ofType: "json") else { fatalError() }
//        guard let path = Bundle.main.path(forResource: "test", ofType: "json") else { fatalError() }
        guard let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data  else { fatalError() }
        guard let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray else { fatalError() }
        
        for raw in jsonResult{
            let pair = raw as! NSDictionary
            
            guard let id = pair["studyItemId"] as? String else {fatalError()}
            guard let dateString = pair["createDate"] as? String else {fatalError()}
            guard let date  = dateformatter.date(from: dateString) else {fatalError()}
            guard let word = pair["word"] as? String else {fatalError()}
            guard let definition = pair["definition"] as? String else {fatalError()}
            let example = pair["example"] as? String
            
            let oldWordPair = OldWordPair(studyItemId: id, creationDate: date, word: word, definition: definition, example: example)
            
            wordPairDict[oldWordPair.studyItemId] = oldWordPair
        }
        print("Loaded \(wordPairDict.count) word pairs.")
    }
    
    func loadTagAssociations(){
        guard let path = Bundle.main.path(forResource: tagAssociationResource, ofType: "json") else { fatalError() }

        guard let jsonData =  try? NSData(contentsOfFile: path, options: [.mappedIfSafe]) as Data  else { fatalError() }
        guard let jsonResult: NSArray = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSArray else { fatalError() }
        
        for raw in jsonResult{
            let ass = raw as! NSDictionary

            guard let studyItemId = ass["studyItemId"] as? String else {fatalError()}
            guard let tagId = ass["tagId"] as? String else {fatalError()}
            
            let tagAss = OldTagAssociation(tagId: tagId, studyItemId: studyItemId)
            
            tagAssociations.append(tagAss)
            
        }
        print("Loaded \(tagAssociations.count) tag associations.")
        
    }
    
    func saveDataToCloudKit() {
        let db = CKContainer.default().publicCloudDatabase
        let privateDb = CKContainer.default().privateCloudDatabase
        
        let errorHandler = ImportErrorHandler()
        
        let queue = OperationQueue()
        
        
        
        for oldTag in tagDict.values{
            let tagOp = OperationCreateTag(tagName: oldTag.tagName, enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
            queue.addOperations([tagOp], waitUntilFinished: true)
            oldTag.newTag = tagOp.tag
            print("Created Tag: \(String(describing: tagOp.tag?.name))")
        }
        
        
        for oldWordPair in wordPairDict.values{
            let wordPairOp = OperationCreateWordPair(wordPairSource: toRealWordPair(oldWordPair: oldWordPair), enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
            queue.addOperations([wordPairOp], waitUntilFinished: true)
            oldWordPair.newWordPair = wordPairOp.wordPair
            
            print("Created word pair: \(String(describing: wordPairOp.wordPair?.word))")
        }
        
        for ass in tagAssociations {
            let tag = tagDict[ass.tagId]!.newTag!
            
            if let wp = wordPairDict[ass.studyItemId]?.newWordPair {
                
                let assOp = OperationCreateTagAssociation(tagId: tag.tagId, wordPairId: wp.pairId, enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
                
                queue.addOperations([assOp], waitUntilFinished: true)
                
                print("created association \(wp.word) tagged \(tag.name)")

            } else {
                print("Failed to find: \(ass.studyItemId)")
            }
        }
        
        for oldMeta in metaDict.values {
            let metaOp = OperationCreateMetaData(metaDataSource: toRealMetaData(oldMetaData: oldMeta), enfocaRef: enfocaRef, db: privateDb, errorDelegate: errorHandler)
            queue.addOperations([metaOp], waitUntilFinished: true)
            print("Created Meta: \(String(describing: metaOp.metaData?.metaId))")
            
        }
    }
    
    private func toRealWordPair(oldWordPair : OldWordPair) -> WordPair{
        return WordPair(pairId: "", word: oldWordPair.word, definition: oldWordPair.definition, dateCreated: oldWordPair.creationDate, gender: .notset, tags: [], example: oldWordPair.example)
    }
    
    private func toRealMetaData(oldMetaData : OldMetaData) -> MetaData{
        
        let wp = wordPairDict[oldMetaData.studyItemId]
        
        guard let pairId =  wp?.newWordPair?.pairId else {fatalError()}
        
        return MetaData(metaId: "", pairId: pairId, dateCreated: oldMetaData.creationDate, dateUpdated: oldMetaData.lastUpdate, incorrectCount: oldMetaData.incorrectCount, totalTime: oldMetaData.totalTime, timedViewCount: oldMetaData.timedViewCount)
    }

}

class ImportErrorHandler : ErrorDelegate {
    func onError(message: String) {
        print(message)
        fatalError()
    }
}

