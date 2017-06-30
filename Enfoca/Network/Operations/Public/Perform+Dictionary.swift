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
    
    //Generate an enfocaId, then create the dictionary
    class func createDictionary(db: CKDatabase, dictionary: UserDictionary, callback : @escaping (_ dictionary : UserDictionary?, _ error : String?) -> ()){
        
        let enfocaIdProvider = EnfocaIdProvider()
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let fetchIncrementAndSaveSeedIfNecessary = FetchIncrementAndSaveSeedIfNecessary(enfocaIdProvider: enfocaIdProvider, db: db, errorDelegate: errorHandler)
        
        let operationCreateDictionary = OperationCreateDictionary(enfocaIdProvider: enfocaIdProvider, dictionarySource: dictionary, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                print("Created Dictionary with EnfocaID \(enfocaIdProvider.enfocaId!)")
                callback(operationCreateDictionary.dictionary, nil)
            }
        }
        
        operationCreateDictionary.addDependency(fetchIncrementAndSaveSeedIfNecessary)
        completeOp.addDependency(operationCreateDictionary)
        
        queue.addOperations([ fetchIncrementAndSaveSeedIfNecessary, operationCreateDictionary, completeOp], waitUntilFinished: false)
        
    }
    
    class func updateDictionary(db: CKDatabase, dictionary: UserDictionary, callback : @escaping (_ dictionary : UserDictionary?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateDictionaryOperation = OperationUpdateDictionary(updatedDictionary: dictionary, enfocaId: dictionary.enfocaId, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            guard let dict = updateDictionaryOperation.dictionary else { fatalError() }
            
            OperationQueue.main.addOperation{
                callback(dict, nil)
            }
        }
        
        completeOp.addDependency(updateDictionaryOperation)
        queue.addOperations([updateDictionaryOperation, completeOp], waitUntilFinished: false)
        
    }
}
