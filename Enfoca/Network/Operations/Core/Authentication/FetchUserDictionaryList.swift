//
//  FetchUserDictionaryList.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class FetchUserDictionaryList : BaseUserOperation {
    
    private var dictionaryList: [Dictionary] = []
    
    override func start() {
        super.start() //Required for base class state
        
        if let _ = user.dictionaryList {
            done()
            return
        }
        
        if isCancelled {
            done()
            return
        }
        
        let sort : NSSortDescriptor = NSSortDescriptor(key: "subject", ascending: true)
        let predicate : NSPredicate = NSPredicate(format: "userRef == %@", user.recordId)
        
        let query: CKQuery = CKQuery(recordType: "Dictionary", predicate: predicate)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        
        execute(operation: operation)
        
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            let dict = CloudKitConverters.toDictionary(from: record)
            
            self.dictionaryList.append(dict)
        }
        
        operation.queryCompletionBlock = {(cursor, error) in
            if let error = error {
                self.handleError(error)
                self.done()
            }
            
            if let cursor = cursor {
                let cursorOp = CKQueryOperation(cursor: cursor)
                self.execute(operation: cursorOp)
                return
            }
            
            self.user.dictionaryList = self.dictionaryList
            
            self.done()
        }
        
        db.add(operation)
    }

}
