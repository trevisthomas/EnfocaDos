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
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var metaData : [MetaData] = []
    private let key : String = "FetchMetaData"
    
    init (enfocaId: NSNumber, db: CKDatabase, progressObserver: ProgressObserver, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        super.init(progressObserver: progressObserver, errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@", enfocaId)
        
        let query: CKQuery = CKQuery(recordType: "MetaData", predicate: predicate)
        
        
        let operation = CKQueryOperation(query: query)
        
        self.progressObserver.startProgress(ofType: key, message: "Starting load of quiz scores")
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            let meta = CloudKitConverters.toMetaData(from: record)
            let message = "".appendingFormat("%.0f", meta.score * 100)
            self.progressObserver.updateProgress(ofType: self.key, message: message)
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
            
            self.progressObserver.endProgress(ofType: self.key, message: "Done all quiz scores loaded.")
            self.done()
        }
        
        db.add(operation)
    }
    
    
    
}
