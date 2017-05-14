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
    
    class func countWordPairs(withTags tags : [Tag], phrase : String?, enfocaId: NSNumber, db: CKDatabase, callback : @escaping (_ count : Int?, _ error : String?) -> ()) {
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let countWordPairsOperation = OperationCountWordPairs(tags: tags, phrase: phrase, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(countWordPairsOperation.count, nil)
            }
        }
        
        completeOp.addDependency(countWordPairsOperation)
        queue.addOperations([countWordPairsOperation, completeOp], waitUntilFinished: false)
    }
    
    class func fetchNextWordPairs(cursor : CKQueryCursor, db: CKDatabase, callback : @escaping([WordPair]?,EnfocaError?)->(), cursorCallback : @escaping(CKQueryCursor)->()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let fetchWordPairsOperation = OperationPagedWordPairs(cursor: cursor, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(fetchWordPairsOperation.wordPairs, nil)
                if let cursor = fetchWordPairsOperation.cursor {
                    cursorCallback(cursor)
                }
            }
        }
        
        completeOp.addDependency(fetchWordPairsOperation)
        queue.addOperations([fetchWordPairsOperation, completeOp], waitUntilFinished: false)
    }
    
    class func fetchWordPairs(tags: [Tag], wordPairOrder: WordPairOrder, phrase : String?, enfocaId: NSNumber, db: CKDatabase, callback : @escaping([WordPair]?,EnfocaError?)->(), cursorCallback : @escaping(CKQueryCursor)->()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let fetchWordPairsOperation = OperationPagedWordPairs(tags: tags, phrase: phrase, order: wordPairOrder, enfocaId: enfocaId, db: db, errorDelegate: errorHandler)
        
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(fetchWordPairsOperation.wordPairs, nil)
                if let cursor = fetchWordPairsOperation.cursor {
                    cursorCallback(cursor)
                }
            }
        }
        
        completeOp.addDependency(fetchWordPairsOperation)
        queue.addOperations([fetchWordPairsOperation, completeOp], waitUntilFinished: false)
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

}
