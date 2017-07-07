//
//  OperationFetchDictionarListForEnfocaRef.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit


//Find any dictionaries that are associated with this ref.  This operation was created to help dictionar delection detect if the dict is shared.
class OperationFetchDictionarListForEnfocaRef: BaseOperation {
    
    private(set) var dictionaryList: [UserDictionary] = []
    private let db : CKDatabase
    private let enfocaRef: CKReference
    
    init (deletedDictionary: UserDictionary, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        
        
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: deletedDictionary.enfocaRef)
        self.enfocaRef = CKReference(recordID: recordId, action: .none)
        
        
        super.init(errorDelegate: errorDelegate)
        
    }
    
    override func start() {
        super.start() //Required for base class state
        
        
        if isCancelled {
            done()
            return
        }
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        let query: CKQuery = CKQuery(recordType: "Dictionary", predicate: predicate)
        
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
            
            self.done()
        }
        
        db.add(operation)
    }
    
}
