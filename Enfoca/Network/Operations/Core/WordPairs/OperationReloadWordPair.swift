//
//  OperationReloadWordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationReloadWordPair : BaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var tagAssociations : [TagAssociation] = []
    private(set) var wordPair: WordPair!
    private let sourceWordPair: WordPair
    
    init (enfocaRef : CKReference, db: CKDatabase, sourceWordPair: WordPair, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.sourceWordPair = sourceWordPair
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let wpRecordId = CKRecordID(recordName: sourceWordPair.pairId)
        
        db.fetch(withRecordID: wpRecordId) { (record: CKRecord?, error: Error?) in
            if let error = error {
                self.handleError(error)
                self.done()
            }
            guard let record = record else { fatalError() }
            
            self.wordPair = CloudKitConverters.toWordPair(from: record)
            
            let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@ && wordRef == %@", self.enfocaRef, wpRecordId)
            
            let query: CKQuery = CKQuery(recordType: "TagAssociation", predicate: predicate)
            
            let operation = CKQueryOperation(query: query)
            
            self.execute(operation: operation, callback: {
                
                self.done()
            })
            
        }
    }
    
    private func execute(operation : CKQueryOperation, callback: @escaping ()->()) {
        operation.recordFetchedBlock = {record in
            let ass = CloudKitConverters.toTagAssociation(from: record)
            self.tagAssociations.append(ass)
           
        }
        
        operation.queryCompletionBlock = {(cursor, error) in
            if let error = error {
                self.handleError(error)
                self.done()
            }
            
            if let cursor = cursor {
                let cursorOp = CKQueryOperation(cursor: cursor)
                self.execute(operation: cursorOp, callback: callback)
                return
            }
            callback()
        }
        
        db.add(operation)
    }
}
