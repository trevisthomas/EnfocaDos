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
    
    
    let metaResource = "study_item_meta"
    let tagResource = "tag"
    let studyItemResource = "study_item"
    let tagAssociationResource = "tag_associations"
    
//    let metaResource = "small_study_item_meta"
//    let tagResource = "small_tag"
//    let studyItemResource = "small_study_item"
//    let tagAssociationResource = "small_tag_associations"
//
    
    //DEPRECATED!
    init(enfocaId id: Int, textView: UITextView?){
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        enfocaId = NSNumber(value: id)
        enfocaRef = nil
        self.textView = textView
    }
    
    init(enfocaRef: String, textView: UITextView?) {
        dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        enfocaId = nil
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: enfocaRef)
        self.enfocaRef = CKReference(recordID: recordId, action: .none)
        self.textView = textView
    }
    
//    var extLogger : (String)->()
    
    var textView: UITextView?

//    func logger(_ message: String) {
//        print(message)
//        
////        invokeLater {
////            self.textView?.text.append(message)
////            self.textView?.text.append("\n")
////            
////            guard let textView = self.textView else { return }
////            let bottom = textView.contentSize.height - textView.bounds.size.height
////            textView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)
////        }
//        
//        
//        
////        extLogger(message)
//    }
    
    func process(){
        
        loadMeta()
        loadWordPairs()
        loadTags()
        loadTagAssociations()
        print("Saving to cloud kit")
        saveDataToCloudKit()
        print("Done")
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
        
        
        saveTags(db: db)

        saveWordPairs(db: db)
        
        saveAssociations(db: db)
        
        saveMeta(db: privateDb)
        
    }
    
    private func saveTags(db: CKDatabase) {
        
        var recordsToUpload : [CKRecord] = []
        var recordsToUploadDict: [CKRecordID: OldTag] = [:]
        
        for oldTag in tagDict.values{
            let tag = CreateTag.create(tagName: oldTag.tagName, enfocaRef: enfocaRef)
            recordsToUpload.append(tag)
            recordsToUploadDict[tag.recordID] = oldTag
            
        }
        
        
        let uploadOperation = CKModifyRecordsOperation(recordsToSave: recordsToUpload, recordIDsToDelete: nil)
        
        uploadOperation.isAtomic = false
        uploadOperation.database = db
        
        uploadOperation.perRecordCompletionBlock = { (record: CKRecord, error: Error?) -> Void in
            let newTag = CloudKitConverters.toTag(from: record)
            
            recordsToUploadDict[record.recordID]!.newTag = newTag
            
            print("Created tag: \(newTag.name)")
        }
        
        // Assign a completion handler
        uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: Error?) -> Void in
            if let error = operationError {
                // Handle the error
                print(error.localizedDescription)
                fatalError(error.localizedDescription)
            }
            if let records = savedRecords {
                print("Created: \(records.count) word pairs.")
            }
        }
        
        OperationQueue().addOperations([uploadOperation], waitUntilFinished: true)

    }
    
    private func saveMeta(db: CKDatabase) {
        
        var recordsToUploadTemp : [CKRecord] = []
        for oldMeta in metaDict.values {
            
            let meta = CreateMetaData.create(metaDataSource: toRealMetaData(oldMetaData: oldMeta), enfocaRef: enfocaRef)
            
            recordsToUploadTemp.append(meta)
        }
        
        for recordsToUpload in recordsToUploadTemp.chunks(400) {
            let uploadOperation = CKModifyRecordsOperation(recordsToSave: recordsToUpload, recordIDsToDelete: nil)
            
            uploadOperation.isAtomic = false
            uploadOperation.database = db
            
            uploadOperation.perRecordCompletionBlock = { (record: CKRecord, error: Error?) -> Void in
                let meta = CloudKitConverters.toMetaData(from: record)
                
                print("Created meta : \(meta.metaId)")
            }
            
            // Assign a completion handler
            uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: Error?) -> Void in
                if let error = operationError {
                    // Handle the error
                    print(error.localizedDescription)
                    fatalError(error.localizedDescription)
                }
                if let records = savedRecords {
                    print("Created: \(records.count) meta data records.")
                }
            }
            
            OperationQueue().addOperations([uploadOperation], waitUntilFinished: true)
    
        }
        
    }
    
    private func saveAssociations(db: CKDatabase) {
        var recordsToUploadTemp : [CKRecord] = []
        
        for ass in tagAssociations {
            let tag = tagDict[ass.tagId]!.newTag!
            
            if let wp = wordPairDict[ass.studyItemId]?.newWordPair {
                
                let ass = CreateTagAssociation.create(tagId: tag.tagId, wordPairId: wp.pairId, enfocaRef: enfocaRef)
                recordsToUploadTemp.append(ass)
//
//                print("created association \(wp.word) tagged \(tag.name)")
                
            } else {
                print("Failed to find: \(ass.studyItemId)")
            }
        }
        
        for recordsToUpload in recordsToUploadTemp.chunks(400) {
            let uploadOperation = CKModifyRecordsOperation(recordsToSave: recordsToUpload, recordIDsToDelete: nil)
            
            uploadOperation.isAtomic = false
            uploadOperation.database = db
            
            uploadOperation.perRecordCompletionBlock = { (record: CKRecord, error: Error?) -> Void in
                let a = CloudKitConverters.toTagAssociation(from: record)
                
                print("Created association : \(a.associationId)")
            }
            
            // Assign a completion handler
            uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: Error?) -> Void in
                if let error = operationError {
                    // Handle the error
                    print(error.localizedDescription)
                    fatalError(error.localizedDescription)
                }
                if let records = savedRecords {
                    print("Created: \(records.count) associations.")
                }
            }
            
            OperationQueue().addOperations([uploadOperation], waitUntilFinished: true)
        }
    }
    private func saveWordPairs(db: CKDatabase) {
        var recordsToUploadTemp : [CKRecord] = []
        var recordsToUploadDict: [CKRecordID: OldWordPair] = [:]
        for oldWordPair in wordPairDict.values {
            let r = CreateWordPair.create(wordPairSource: toRealWordPair(oldWordPair: oldWordPair), enfocaRef: enfocaRef)
            
            recordsToUploadTemp.append(r)
            recordsToUploadDict[r.recordID] = oldWordPair
            
        }
        
        for recordsToUpload in recordsToUploadTemp.chunks(400) {
            let uploadOperation = CKModifyRecordsOperation(recordsToSave: recordsToUpload, recordIDsToDelete: nil)
            
            uploadOperation.isAtomic = false
            uploadOperation.database = db
            
            uploadOperation.perRecordCompletionBlock = { (record: CKRecord, error: Error?) -> Void in
                let wp = CloudKitConverters.toWordPair(from: record)
                
                recordsToUploadDict[record.recordID]!.newWordPair = wp
                
                print("Created word pair: \(wp.word)")
            }
            
            // Assign a completion handler
            uploadOperation.modifyRecordsCompletionBlock = { (savedRecords: [CKRecord]?, deletedRecords: [CKRecordID]?, operationError: Error?) -> Void in
                if let error = operationError {
                    // Handle the error
                    print(error.localizedDescription)
                    fatalError(error.localizedDescription)
                }
                if let records = savedRecords {
                    print("Created: \(records.count) word pairs.")
                }
            }
            
            OperationQueue().addOperations([uploadOperation], waitUntilFinished: true)
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
        
        
        getAppDelegate().presentAlert(title: "Import error", message: message) { 
            //
        }
//        fatalError()
    }
}

