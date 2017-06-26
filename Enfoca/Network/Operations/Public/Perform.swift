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
    
    //This is/will-be the new authentication method
    class func loadUserDictionaryList(db: CKDatabase, callback : @escaping (_ dictionaryList :  [Dictionary]?,_ error : String?) -> ()){
        
        let user : InternalUser = InternalUser()
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let completeOp = BlockOperation {
            //            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //            print ("Tags loaded: \(fetchOp.tags)")
            OperationQueue.main.addOperation{
                print(user.recordId)
                callback(user.dictionaryList, nil)
            }
        }
        
        let fetchUserId = FetchUserRecordId(user: user, db: db, errorDelegate: errorHandler)
        let cloudAuth = CloudAuthOperation(user: user, db: db, errorDelegate: errorHandler)
        let fetchUserRecord = FetchUserRecordOperation(user: user, db: db, errorDelegate: errorHandler)
        
        let fetchDictionaryList = FetchUserDictionaryList(user: user, db: db, errorDelegate: errorHandler)
        
        fetchUserId.addDependency(cloudAuth)
        fetchUserRecord.addDependency(fetchUserId)
        fetchDictionaryList.addDependency(fetchUserRecord)
        
        completeOp.addDependency(fetchDictionaryList)
        
        queue.addOperations([fetchUserId, cloudAuth, fetchUserRecord, fetchDictionaryList, completeOp], waitUntilFinished: false)
        
    }
    
    class func authentcate(db: CKDatabase, callback : @escaping (_ userTuple : (Int, CKRecordID)?,_ error : String?) -> ()){
        
        let user : InternalUser = InternalUser()
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let completeOp = BlockOperation {
            //            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            //            print ("Tags loaded: \(fetchOp.tags)")
            OperationQueue.main.addOperation{
                print(user.recordId)
                callback((user.enfocaId, user.recordId), nil)
            }
        }
        
        let fetchUserId = FetchUserRecordId(user: user, db: db, errorDelegate: errorHandler)
        let cloudAuth = CloudAuthOperation(user: user, db: db, errorDelegate: errorHandler)
        let fetchUserRecord = FetchUserRecordOperation(user: user, db: db, errorDelegate: errorHandler)
        let fetchOrCreateEnfocaId = FetchOrCreateEnfocaId(user: user, db: db, errorDelegate: errorHandler)
        let fetchIncrementAndSaveSeedIfNecessary = FetchIncrementAndSaveSeedIfNecessary(user: user, db: db, errorDelegate: errorHandler)
        
        fetchUserId.addDependency(cloudAuth)
        fetchUserRecord.addDependency(fetchUserId)
        fetchIncrementAndSaveSeedIfNecessary.addDependency(fetchUserRecord)
        fetchOrCreateEnfocaId.addDependency(fetchIncrementAndSaveSeedIfNecessary)
        completeOp.addDependency(fetchOrCreateEnfocaId)
        
        queue.addOperations([fetchUserId, cloudAuth, fetchUserRecord, fetchOrCreateEnfocaId, fetchIncrementAndSaveSeedIfNecessary, completeOp], waitUntilFinished: false)
        
    }
    
    class func initializeDataStore(dataStore: DataStore, enfocaId: NSNumber, db: CKDatabase, privateDb: CKDatabase, progressObserver: ProgressObserver, callback : @escaping (DataStore?, EnfocaError?)->()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        
        
        let fetchTagAssociations = OperationFetchTagAssociations(enfocaId: enfocaId, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchTags = OperationFetchTags(enfocaId: enfocaId, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchWordPairs = OperationFetchWordPairs(enfocaId: enfocaId, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        
        let fetchMetaData = OperationFetchMetaData(enfocaId: enfocaId, db: privateDb, progressObserver: progressObserver, errorDelegate: errorHandler)
        
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

