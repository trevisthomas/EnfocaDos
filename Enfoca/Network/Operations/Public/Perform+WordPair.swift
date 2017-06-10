//
//  Perform+WordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

extension Perform{
    class func createWordPair(wordPair : WordPair, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ wordPair : WordPair?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        let createWordPairOperation = OperationCreateWordPair(wordPairSource: wordPair, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            
            guard let wp = createWordPairOperation.wordPair else { fatalError() }
            
            OperationQueue.main.addOperation{
                callback(wp, nil)
            }
        }
        
        
        completeOp.addDependency(createWordPairOperation)
        queue.addOperations([createWordPairOperation, completeOp], waitUntilFinished: false)
    }
    
    class func createTagAssociation(tagId: String, wordPairId: String, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ tagAssociation : TagAssociation?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let createTagAssociation = OperationCreateTagAssociation(tagId: tagId, wordPairId: wordPairId, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createTagAssociation.tagAssociation, nil)
            }
        }
        
        completeOp.addDependency(createTagAssociation)
        queue.addOperations([createTagAssociation, completeOp], waitUntilFinished: false)
    }
    
    class func deleteTagAssociation(tagAssociation: TagAssociation, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ associationId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteTagAssociation = OperationDeleteRecord(recordName: tagAssociation.associationId, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteTagAssociation.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteTagAssociation)
        queue.addOperations([deleteTagAssociation, completeOp], waitUntilFinished: false)
        
    }
    
    class func updateWordPair(wordPair : WordPair, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ wordPair : WordPair?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateWordPairOperation = OperationUpdateWordPair(updatedWordPair: wordPair, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            guard let wp = updateWordPairOperation.wordPair else { fatalError() }
            
            OperationQueue.main.addOperation{
                callback(wp, nil)
            }
        }
        
        completeOp.addDependency(updateWordPairOperation)
        queue.addOperations([updateWordPairOperation, completeOp], waitUntilFinished: false)
    }
    
    
    class func deleteWordPair(wordPair: WordPair, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ pairId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteRecord = OperationDeleteRecord(recordName: wordPair.pairId, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteRecord.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteRecord)
        queue.addOperations([deleteRecord, completeOp], waitUntilFinished: false)
        
    }
    
    class func deleteTag(tag: Tag, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ pairId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteRecord = OperationDeleteRecord(recordName: tag.tagId, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteRecord.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteRecord)
        queue.addOperations([deleteRecord, completeOp], waitUntilFinished: false)
        
    }

    class func createMetaData(metaDataSource: MetaData, enfocaId: NSNumber, db: CKDatabase, callback : @escaping(_ metaData: MetaData?, _ error: String?)->()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let createMetaData = OperationCreateMetaData(metaDataSource: metaDataSource, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createMetaData.metaData, nil)
            }
        }
        
        completeOp.addDependency(createMetaData)
        queue.addOperations([createMetaData, completeOp], waitUntilFinished: false)
    }
    
    class func updateMetaData(updatedMetaData: MetaData, enfocaId: NSNumber, db: CKDatabase, callback : @escaping(_ metaData: MetaData?, _ error: String?)->()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateMetaData = OperationUpdateMetaData(updatedMetaData: updatedMetaData, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(updateMetaData.metaData, nil)
            }
        }
        
        completeOp.addDependency(updateMetaData)
        queue.addOperations([updateMetaData, completeOp], waitUntilFinished: false)
    }
    
}
