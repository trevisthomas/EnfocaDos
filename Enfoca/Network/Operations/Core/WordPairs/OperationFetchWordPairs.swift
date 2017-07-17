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
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var wordPairs : [WordPair] = []
    static let key : String = "FetchWordPairs"
    private let size: Int
    private var count: Int = 0
    
    init (sizeEstimate: Int, enfocaRef : CKReference, db: CKDatabase, progressObserver: ProgressObserver, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.size = sizeEstimate
        super.init(progressObserver: progressObserver, errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        let sort : NSSortDescriptor = NSSortDescriptor(key: "word", ascending: true)
//        let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@", enfocaId)
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let query: CKQuery = CKQuery(recordType: "WordPair", predicate: predicate)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        
        self.progressObserver.startProgress(ofType: OperationFetchWordPairs.key, message: "Starting load vocabulary", size: self.size)
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            let wp = CloudKitConverters.toWordPair(from: record)
            self.count += 1
            self.progressObserver.updateProgress(ofType: OperationFetchWordPairs.key, message: "loaded \(wp.word)", count: self.count)
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
            
            self.progressObserver.endProgress(ofType: OperationFetchWordPairs.key, message: "Done fetching vocabulary.", total: self.count)
            self.done()
        }
        
        db.add(operation)
    }
    
    
    
}
