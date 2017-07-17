//
//  OperationFetchTagAssociations.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/6/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationFetchTagAssociations : MonitoredBaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var tagAssociations : [TagAssociation] = []
    static let key : String = "FetchTagAssociations"
    private let sizeEstimate: Int
    private var currentCount: Int = 0
    
    init (sizeEstimate: Int, enfocaRef : CKReference, db: CKDatabase, progressObserver: ProgressObserver, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.sizeEstimate = sizeEstimate
        super.init(progressObserver: progressObserver, errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        self.progressObserver.startProgress(ofType: OperationFetchTagAssociations.key, message: "Loading tag associations.", size: sizeEstimate)
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let query: CKQuery = CKQuery(recordType: "TagAssociation", predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            let ass = CloudKitConverters.toTagAssociation(from: record)
            self.tagAssociations.append(ass)
            self.currentCount += 1
            self.progressObserver.updateProgress(ofType: OperationFetchTagAssociations.key, message: "association \(self.tagAssociations.count)", count: self.currentCount)
            
            
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
            self.progressObserver.endProgress(ofType: OperationFetchTagAssociations.key, message: "Done loading associatoins.", total: self.currentCount)
            self.done()
        }
        
        db.add(operation)
    }
    
}
