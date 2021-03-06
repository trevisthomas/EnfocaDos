//
//  Perform+Tags.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

extension Perform{

    class func createTag(fromTag: Tag, enfocaRef: CKReference, db: CKDatabase, callback : @escaping (_ tag : Tag?, _ error : String?) -> ()){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let createTagOperation = OperationCreateTag(fromTag: fromTag, enfocaRef: enfocaRef, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(createTagOperation.tag, nil)
            }
        }
        
        completeOp.addDependency(createTagOperation)
        queue.addOperations([createTagOperation, completeOp], waitUntilFinished: false)
    }
    
    class func updateTag(updatedTag: Tag, db: CKDatabase, callback : @escaping (_ tag : Tag?, _ error : String?) -> () ){
        
        let queue = OperationQueue()
        let errorHandler = ErrorHandler(queue: queue, callback: callback)
        
        let updateTagOperation = OperationUpdateTag(updatedTag: updatedTag, db: db, errorDelegate: errorHandler)
        let completeOp = BlockOperation {
            OperationQueue.main.addOperation{
                callback(updateTagOperation.tag, nil)
            }
        }
        
        completeOp.addDependency(updateTagOperation)
        queue.addOperations([updateTagOperation, completeOp], waitUntilFinished: false)
    }
}

