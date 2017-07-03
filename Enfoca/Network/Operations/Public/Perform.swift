//
//  OperationsDemo.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class Perform {
    
    class func initializeDataStore(dataStore: DataStore, enfocaRef: CKReference, db: CKDatabase, privateDb: CKDatabase, progressObserver: ProgressObserver, callback : @escaping (DataStore?, EnfocaError?)->()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        
        
        let fetchTagAssociations = OperationFetchTagAssociations(enfocaRef: enfocaRef, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchTags = OperationFetchTags(enfocaRef: enfocaRef, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchWordPairs = OperationFetchWordPairs(enfocaRef: enfocaRef, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        
        let fetchMetaData = OperationFetchMetaData(enfocaRef: enfocaRef, db: privateDb, progressObserver: progressObserver, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            print("Initializing data store")
            dataStore.initialize(tags: fetchTags.tags, wordPairs: fetchWordPairs.wordPairs, tagAssociations: fetchTagAssociations.tagAssociations, metaData: fetchMetaData.metaData, progressObserver: progressObserver)
            
            print("DataStore initialized with \(dataStore.wordPairDictionary.count) word pairs, \(dataStore.tagDictionary.count) tags, \(dataStore.tagAssociations.count) associations and \(dataStore.metaDataDictionary.count) quiz stats.")
            
            
            OperationQueue.main.addOperation{
                callback(dataStore, nil)
            }
        }
        
        completeOp.addDependency(fetchTagAssociations)
        completeOp.addDependency(fetchTags)
        completeOp.addDependency(fetchWordPairs)
        completeOp.addDependency(fetchMetaData)
        
        
        queue.addOperations([fetchWordPairs, fetchTags, fetchTagAssociations, fetchMetaData, completeOp], waitUntilFinished: false)
    }
    
    class func deleteAllRecords(dataStore: DataStore, enfocaId: NSNumber, db: CKDatabase) {
        
        
        
        var recordIds : [CKRecordID] = []
        
        
        let tagRecords = dataStore.tagDictionary.values.map { (tag:Tag) -> CKRecordID in
            return CloudKitConverters.toCKRecordID(fromRecordName: tag.tagId)
        }
        
        let pairRecords = dataStore.wordPairDictionary.values.map { (wp:WordPair) -> CKRecordID in
            return CloudKitConverters.toCKRecordID(fromRecordName: wp.pairId)
        }
        
        let assRecords = dataStore.tagAssociations.map { (tagAss:TagAssociation) -> CKRecordID in
            return CloudKitConverters.toCKRecordID(fromRecordName: tagAss.associationId)
        }
        
        let metaRecords = dataStore.metaDataDictionary.values.map { (meta:MetaData) -> CKRecordID in
            return CloudKitConverters.toCKRecordID(fromRecordName: meta.metaId)
        }
        
        recordIds.append(contentsOf: tagRecords)
        recordIds.append(contentsOf: pairRecords)
        recordIds.append(contentsOf: assRecords)
        recordIds.append(contentsOf: metaRecords)
        
        let chunkSize = 400
        let chunks = stride(from: 0, to: recordIds.count, by: chunkSize).map {
            Array(recordIds[$0..<min($0 + chunkSize, recordIds.count)])
        }
        
        
        var operations : [Operation] = []
        for chunk in chunks {
            
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: chunk)
            
            operation.database = db
            
            operation.savePolicy = .allKeys
            operation.queuePriority = .veryHigh
            
            operation.perRecordCompletionBlock = {
                (record: CKRecord?, error: Error?) in
                if let error = error {
                    print(error)
                } else {
                    print("deleted \(String(describing: record?.recordID.recordName))")
                }
            }
            
            operation.modifyRecordsCompletionBlock = {
                (savedRecords: [CKRecord]?, deletedRecordIDs: [CKRecordID]?, error: Error?) in
                
                if let error = error {
                    print(error)
                } else {
                    guard let deletedRecordIDs = deletedRecordIDs else { return }
                    print("deleted \(deletedRecordIDs.count) records")
                }
            }
            operations.append(operation)
        }
        
        let queue = OperationQueue()
        queue.addOperations(operations, waitUntilFinished: true)
        
    }
    
    class func loadOrCreateConch(enfocaRef: CKReference, db: CKDatabase, callback : @escaping ((String, Bool)?, EnfocaError?)->()){
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        
        
        let loadOrCreateConch = OperationLoadOrCreateConch(enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            guard let conch = loadOrCreateConch.conch else { fatalError("Failed to create or load conch") }
            if loadOrCreateConch.isNew {
                print("Created conch \(conch)")
            } else {
                print("Loaded conch \(conch)")
            }
            
            OperationQueue.main.addOperation{
                callback((conch, loadOrCreateConch.isNew), nil)
            }
        }
        
        completeOp.addDependency(loadOrCreateConch)
        
        queue.addOperations([loadOrCreateConch, completeOp], waitUntilFinished: false)
    }
    
    class func resetConch(enfocaRef: CKReference, db: CKDatabase, callback : @escaping (String?, EnfocaError?)->()){
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateConch = OperationResetConch(enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            guard let conch = updateConch.conch else { fatalError("failed to reset conch") }
            print("New conch \(conch)")
            
            OperationQueue.main.addOperation{
                callback(conch, nil)
            }
        }
        
        completeOp.addDependency(updateConch)
        
        queue.addOperations([updateConch, completeOp], waitUntilFinished: false)
    }
}

class ErrorHandler<T> : ErrorDelegate {
    let callback: ( T?, _ error : String?) -> ()
    let queue: OperationQueue?
    init (queue : OperationQueue?, callback : @escaping ( T?, _ error : String?) -> ()) {
        self.callback = callback
        self.queue = queue
    }
    
    func onError(message: String) {
        queue?.cancelAllOperations()
        OperationQueue.main.addOperation {
            self.callback(nil, message)
        }
    }
}

