//
//  Perform+Dictionary.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

extension Perform {
    //This is/will-be the new authentication method
    class func initialize(db: CKDatabase, callback : @escaping ( (CKRecordID, [UserDictionary])?, String?) -> ()){
        
        let user : InternalUser = InternalUser()
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                print(user.recordId)
                
                guard let list = user.dictionaryList else {
                    callback((user.recordId, []), nil)
                    return
                }
                callback((user.recordId, list), nil)
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
    
    class func createDictionary(db: CKDatabase, dictionary: UserDictionary, callback : @escaping (_ dictionary : UserDictionary?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let operationCreateDictionary = OperationCreateDictionary(dictionarySource: dictionary, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                print("Created Dictionary with EnfocaRef \(operationCreateDictionary.dictionary!.enfocaRef)")
                callback(operationCreateDictionary.dictionary, nil)
            }
        }
        
        completeOp.addDependency(operationCreateDictionary)
        
        queue.addOperations([ operationCreateDictionary, completeOp], waitUntilFinished: false)
        
    }
    
    class func updateDictionary(db: CKDatabase, dictionary: UserDictionary, callback : @escaping (_ dictionary : UserDictionary?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateDictionaryOperation = OperationUpdateDictionary(updatedDictionary: dictionary, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            guard let dict = updateDictionaryOperation.dictionary else { fatalError() }
            
            OperationQueue.main.addOperation{
                callback(dict, nil)
            }
        }
        
        completeOp.addDependency(updateDictionaryOperation)
        queue.addOperations([updateDictionaryOperation, completeOp], waitUntilFinished: false)
        
    }
    
    class func deleteDictionary(dictionary: UserDictionary, db: CKDatabase, privateDb: CKDatabase, callback : @escaping (_ dictionaryId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteRecord = OperationDeleteRecord(recordName: dictionary.dictionaryId, db: db, errorDelegate: errorHandler)
        
        let fetchOtherDicts = OperationFetchDictionarListForEnfocaRef(deletedDictionary: dictionary, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            
            if fetchOtherDicts.dictionaryList.count == 0 {
                fetchRecordsToDeleteThenDelete(metaOnly: false, dictionary: dictionary, db: db, privateDb: privateDb, callback: callback)
            } else {
                //Only delete meta
                fetchRecordsToDeleteThenDelete(metaOnly: true, dictionary: dictionary, db: db, privateDb: privateDb, callback: callback)
            }
        }
        
        fetchOtherDicts.addDependency(deleteRecord)
        completeOp.addDependency(fetchOtherDicts)
        queue.addOperations([deleteRecord, fetchOtherDicts, completeOp], waitUntilFinished: false)
        
    }
    
    private class func fetchRecordsToDeleteThenDelete(metaOnly: Bool = false, dictionary: UserDictionary, db: CKDatabase, privateDb: CKDatabase, callback : @escaping (_ dictionaryId : String?, _ error : String?) -> ()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        let progressObserver = DefaultProgressObserver()
        
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: dictionary.enfocaRef)
        let enfocaRef = CKReference(recordID: recordId, action: .none)
        
        let fetchTagAssociations = OperationFetchTagAssociations(enfocaRef: enfocaRef, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchTags = OperationFetchTags(enfocaRef: enfocaRef, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchWordPairs = OperationFetchWordPairs(enfocaRef: enfocaRef, db: db, progressObserver: progressObserver, errorDelegate: errorHandler)
        let fetchMetaData = OperationFetchMetaData(enfocaRef: enfocaRef, db: privateDb, progressObserver: progressObserver, errorDelegate: errorHandler)
        
        let deleteConch = OperationDeleteConch(enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            
            
            var recordIds : [CKRecordID] = []
            var metaRecordIds : [CKRecordID] = []
            
            
            let tagRecords = fetchTags.tags.map { (tag:Tag) -> CKRecordID in
                return CloudKitConverters.toCKRecordID(fromRecordName: tag.tagId)
            }
            
            let pairRecords = fetchWordPairs.wordPairs.map { (wp:WordPair) -> CKRecordID in
                return CloudKitConverters.toCKRecordID(fromRecordName: wp.pairId)
            }
            
            let assRecords = fetchTagAssociations.tagAssociations.map { (tagAss:TagAssociation) -> CKRecordID in
                return CloudKitConverters.toCKRecordID(fromRecordName: tagAss.associationId)
            }
            
            let metaRecords = fetchMetaData.metaData.map { (meta:MetaData) -> CKRecordID in
                return CloudKitConverters.toCKRecordID(fromRecordName: meta.metaId)
            }
            
            
            
            recordIds.append(contentsOf: tagRecords)
            recordIds.append(contentsOf: pairRecords)
            recordIds.append(contentsOf: assRecords)
            
            metaRecordIds.append(contentsOf: metaRecords)
            
            deleteAllRecords(recordIds: metaRecordIds, db: privateDb, callback: { (deleted:[CKRecordID]?, error: String?) in
                if let error = error {
                    callback(dictionary.dictionaryId, error)
                }
                
                if !metaOnly {
                    
                    deleteAllRecords(recordIds: recordIds, db: db, callback: { (_: [CKRecordID]?, error: String?) in
                        invokeLater {
                            if let error = error {
                                callback(dictionary.dictionaryId, error)
                            } else {
                                callback(dictionary.dictionaryId, nil)
                            }
                        }
                    })
                } else {
                    invokeLater {
                        callback(dictionary.dictionaryId, nil)
                    }
                }
            })
        }
        
        if metaOnly {
            completeOp.addDependency(fetchMetaData)
            queue.addOperations([fetchMetaData, completeOp], waitUntilFinished: false)
        } else {
            completeOp.addDependency(fetchTagAssociations)
            completeOp.addDependency(fetchTags)
            completeOp.addDependency(fetchWordPairs)
            completeOp.addDependency(fetchMetaData)
            completeOp.addDependency(deleteConch)
            queue.addOperations([fetchWordPairs, fetchTags, fetchTagAssociations, fetchMetaData, deleteConch, completeOp], waitUntilFinished: false)
        }
        
        
    }
    
    class func deleteAllRecords(recordIds: [CKRecordID], db: CKDatabase, callback: @escaping ([CKRecordID]?, String?)->()) {
        
        var deletedRecordIDs : [CKRecordID] = []
        
        let completeOp = BlockOperation {
            callback(deletedRecordIDs, nil)
        }
        
        var operations : [Operation] = []
        
        operations.append(completeOp)
        
        for chunk in recordIds.chunks(400) {
            
            let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: chunk)
            
            operation.database = db
            
            operation.savePolicy = .allKeys
            operation.queuePriority = .veryHigh
            
            operation.perRecordCompletionBlock = {
                (record: CKRecord?, error: Error?) in
                if let error = error {
                    callback(nil, error.localizedDescription)
                } else {
//                    print("deleted \(String(describing: record?.recordID.recordName))")
                }
            }
            
            operation.modifyRecordsCompletionBlock = {
                (savedRecords: [CKRecord]?, deleted: [CKRecordID]?, error: Error?) in
                
                if let error = error {
                    callback(nil, error.localizedDescription)
                } else {
                    guard let deleted = deleted else { return }
                    deletedRecordIDs.append(contentsOf: deleted)
                }
            }
            completeOp.addDependency(operation)
            operations.append(operation)
        }
        
        let queue = OperationQueue()
        queue.addOperations(operations, waitUntilFinished: false)
        
    }

    
}


