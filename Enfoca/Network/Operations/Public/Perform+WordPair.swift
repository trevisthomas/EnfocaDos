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
    class func createWordPair(wordPair : WordPair, enfocaRef: CKReference, db: CKDatabase, callback : @escaping (_ wordPair : WordPair?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        let createWordPairOperation = OperationCreateWordPair(wordPairSource: wordPair, enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            
            guard let wp = createWordPairOperation.wordPair else { fatalError() }
            
            OperationQueue.main.addOperation{
                callback(wp, nil)
            }
        }
        
        
        completeOp.addDependency(createWordPairOperation)
        queue.addOperations([createWordPairOperation, completeOp], waitUntilFinished: false)
    }
    
    class func createTagAssociation(tagId: String, wordPairId: String, enfocaRef: CKReference, db: CKDatabase, callback : @escaping (_ tagAssociation : TagAssociation?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let createTagAssociation = OperationCreateTagAssociation(tagId: tagId, wordPairId: wordPairId, enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createTagAssociation.tagAssociation, nil)
            }
        }
        
        completeOp.addDependency(createTagAssociation)
        queue.addOperations([createTagAssociation, completeOp], waitUntilFinished: false)
    }
    
    class func deleteTagAssociation(tagAssociation: TagAssociation, db: CKDatabase, callback : @escaping (_ associationId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteTagAssociation = OperationDeleteRecord(recordName: tagAssociation.associationId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteTagAssociation.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteTagAssociation)
        queue.addOperations([deleteTagAssociation, completeOp], waitUntilFinished: false)
        
    }
    
    class func updateWordPair(wordPair : WordPair, db: CKDatabase, callback : @escaping (_ wordPair : WordPair?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateWordPairOperation = OperationUpdateWordPair(updatedWordPair: wordPair, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            guard let wp = updateWordPairOperation.wordPair else { fatalError() }
            
            OperationQueue.main.addOperation{
                callback(wp, nil)
            }
        }
        
        completeOp.addDependency(updateWordPairOperation)
        queue.addOperations([updateWordPairOperation, completeOp], waitUntilFinished: false)
    }
    
    
    class func deleteWordPair(wordPair: WordPair, db: CKDatabase, callback : @escaping (_ pairId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteRecord = OperationDeleteRecord(recordName: wordPair.pairId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteRecord.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteRecord)
        queue.addOperations([deleteRecord, completeOp], waitUntilFinished: false)
        
    }
    
    class func deleteDictionary(dictionary: UserDictionary, db: CKDatabase, callback : @escaping (_ dictionaryId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteRecord = OperationDeleteRecord(recordName: dictionary.dictionaryId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteRecord.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteRecord)
        queue.addOperations([deleteRecord, completeOp], waitUntilFinished: false)
        
    }
    
    class func deleteTag(tag: Tag, db: CKDatabase, callback : @escaping (_ pairId : String?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let deleteRecord = OperationDeleteRecord(recordName: tag.tagId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(deleteRecord.deletedRecordName, nil)
            }
        }
        
        completeOp.addDependency(deleteRecord)
        queue.addOperations([deleteRecord, completeOp], waitUntilFinished: false)
        
    }

    class func createMetaData(metaDataSource: MetaData, enfocaRef: CKReference, db: CKDatabase, callback : @escaping(_ metaData: MetaData?, _ error: String?)->()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let createMetaData = OperationCreateMetaData(metaDataSource: metaDataSource, enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createMetaData.metaData, nil)
            }
        }
        
        completeOp.addDependency(createMetaData)
        queue.addOperations([createMetaData, completeOp], waitUntilFinished: false)
    }
    
    class func updateMetaData(updatedMetaData: MetaData, db: CKDatabase, callback : @escaping(_ metaData: MetaData?, _ error: String?)->()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateMetaData = OperationUpdateMetaData(updatedMetaData: updatedMetaData, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(updateMetaData.metaData, nil)
            }
        }
        
        completeOp.addDependency(updateMetaData)
        queue.addOperations([updateMetaData, completeOp], waitUntilFinished: false)
    }
    
    //Reload all tags from DB
    class func reloadTags(db: CKDatabase, enfocaRef: CKReference, callback : @escaping([Tag]?, _ error: String?)->()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let fetchTags = OperationFetchTags(enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                
                callback(fetchTags.tags, nil)
            }
        }
        
        completeOp.addDependency(fetchTags)
        queue.addOperations([fetchTags, completeOp], waitUntilFinished: false)
        
    }
    
    class func reloadWordPair(db: CKDatabase, enfocaRef: CKReference, sourceWordPair: WordPair, callback : @escaping((WordPair, [TagAssociation])?, _ error: String?)->()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let reloadWordPair = OperationReloadWordPair(enfocaRef: enfocaRef, db: db, sourceWordPair: sourceWordPair, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                
                callback((reloadWordPair.wordPair, reloadWordPair.tagAssociations), nil)
            }
        }
        
        completeOp.addDependency(reloadWordPair)
        queue.addOperations([reloadWordPair, completeOp], waitUntilFinished: false)
    }
}
