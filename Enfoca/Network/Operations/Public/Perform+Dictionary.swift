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
    class func initialize(db: CKDatabase, callback : @escaping ( (CKRecordID, [Dictionary])?, String?) -> ()){
        
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
    
    //Generate an enfocaId, then create the dictionary
    class func createDictionary(db: CKDatabase, dictionary: Dictionary, callback : @escaping (_ dictionary : Dictionary?, _ error : String?) -> ()){
        
        let user : InternalUser = InternalUser()
        
//        user.recordId = CloudKitConverters.toCKRecordID(fromRecordName: dictionary.userRef)
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let fetchIncrementAndSaveSeedIfNecessary = FetchIncrementAndSaveSeedIfNecessary(user: user, db: db, errorDelegate: errorHandler)
        
        let operationCreateDictionary = OperationCreateDictionary(enfocaId: user.enfocaId, dictionarySource: dictionary, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                print(user.recordId)
                callback(operationCreateDictionary.dictionary, nil)
            }
        }
        
        operationCreateDictionary.addDependency(fetchIncrementAndSaveSeedIfNecessary)
        completeOp.addDependency(operationCreateDictionary)
        
        queue.addOperations([ fetchIncrementAndSaveSeedIfNecessary, operationCreateDictionary, completeOp], waitUntilFinished: false)
        
    }
    
//    class func authentcate(db: CKDatabase, callback : @escaping (_ userTuple : (Int, CKRecordID)?,_ error : String?) -> ()){
//        
//        let user : InternalUser = InternalUser()
//        let queue = OperationQueue()
//        let errorHandler = ErrorHandler(queue: queue, callback: callback)
//        
//        let completeOp = BlockOperation {
//            //            UIApplication.shared.isNetworkActivityIndicatorVisible = false
//            //            print ("Tags loaded: \(fetchOp.tags)")
//            OperationQueue.main.addOperation{
//                print(user.recordId)
//                callback((user.enfocaId, user.recordId), nil)
//            }
//        }
//        
//        let fetchUserId = FetchUserRecordId(user: user, db: db, errorDelegate: errorHandler)
//        let cloudAuth = CloudAuthOperation(user: user, db: db, errorDelegate: errorHandler)
//        let fetchUserRecord = FetchUserRecordOperation(user: user, db: db, errorDelegate: errorHandler)
//        let fetchOrCreateEnfocaId = FetchOrCreateEnfocaId(user: user, db: db, errorDelegate: errorHandler)
//        let fetchIncrementAndSaveSeedIfNecessary = FetchIncrementAndSaveSeedIfNecessary(user: user, db: db, errorDelegate: errorHandler)
//        
//        fetchUserId.addDependency(cloudAuth)
//        fetchUserRecord.addDependency(fetchUserId)
//        fetchIncrementAndSaveSeedIfNecessary.addDependency(fetchUserRecord)
//        fetchOrCreateEnfocaId.addDependency(fetchIncrementAndSaveSeedIfNecessary)
//        completeOp.addDependency(fetchOrCreateEnfocaId)
//        
//        queue.addOperations([fetchUserId, cloudAuth, fetchUserRecord, fetchOrCreateEnfocaId, fetchIncrementAndSaveSeedIfNecessary, completeOp], waitUntilFinished: false)
//        
//    }
}
