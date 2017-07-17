//
//  OperationFetchMetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationFetchMetaData : MonitoredBaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var metaData : [MetaData] = []
    static let key : String = "FetchMetaData"
    private let size: Int
    private var count: Int = 0
    
    init (sizeEstimate: Int, enfocaRef: CKReference, db: CKDatabase, progressObserver: ProgressObserver, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.size = sizeEstimate
        super.init(progressObserver: progressObserver, errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let query: CKQuery = CKQuery(recordType: "MetaData", predicate: predicate)
        
        
        let operation = CKQueryOperation(query: query)
        
        self.progressObserver.startProgress(ofType: OperationFetchMetaData.key, message: "Starting load of quiz scores", size: self.size)
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            let meta = CloudKitConverters.toMetaData(from: record)
            let message = "".appendingFormat("%.0f", meta.score * 100)
            self.count += 1
            self.progressObserver.updateProgress(ofType: OperationFetchMetaData.key, message: message, count: self.count)
            self.metaData.append(meta)
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
            
            self.progressObserver.endProgress(ofType: OperationFetchMetaData.key, message: "Done all quiz scores loaded.", total: self.size)
            self.done()
        }
        
        db.add(operation)
    }
    
    
    
}
