//
//  OperationFetchWordPairs.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationFetchWordPairs : MonitoredBaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var wordPairs : [WordPair] = []
    private let key : String = "FetchWordPairs"
    
    init (enfocaId: NSNumber, db: CKDatabase, progressObserver: ProgressObserver, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        super.init(progressObserver: progressObserver, errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let sort : NSSortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@", enfocaId)
        
        let query: CKQuery = CKQuery(recordType: "WordPair", predicate: predicate)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        
        self.progressObserver.startProgress(ofType: key, message: "Starting load vocabulary")
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            let wp = CloudKitConverters.toWordPair(from: record)
            self.progressObserver.updateProgress(ofType: self.key, message: "loaded \(wp.word)")
            self.wordPairs.append(wp)
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
            
            self.progressObserver.endProgress(ofType: self.key, message: "Done fetching vocabulary.")
            self.done()
        }
        
        db.add(operation)
    }
    
    
    
}
