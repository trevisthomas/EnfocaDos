//
//  OperationFetchTags.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationFetchTags : MonitoredBaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var tags : [Tag] = []
    static let key : String = "FetchTags"
    private let size: Int
    private var count: Int = 0
    
    convenience init(enfocaRef: CKReference, db: CKDatabase, errorDelegate: ErrorDelegate) {
        self.init(sizeEstimate: 0, enfocaRef: enfocaRef, db: db, progressObserver: DefaultProgressObserver(), errorDelegate: errorDelegate)
    }
    
    init (sizeEstimate: Int, enfocaRef: CKReference, db: CKDatabase, progressObserver: ProgressObserver, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.size = sizeEstimate
        super.init(progressObserver: progressObserver, errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start() //Required for base class state
        
        self.progressObserver.startProgress(ofType: OperationFetchTags.key, message: "Loading tags", size: self.size)
        
        let sort : NSSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let query: CKQuery = CKQuery(recordType: "Tag", predicate: predicate)
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        
        execute(operation: operation)
    }
    
    private func execute(operation : CKQueryOperation) {
        operation.recordFetchedBlock = {record in
            
            let tag = CloudKitConverters.toTag(from: record)
            self.tags.append(tag)
            self.count += 1
            self.progressObserver.updateProgress(ofType: OperationFetchTags.key, message: "tag: \(tag.name)", count: self.count)
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
            self.progressObserver.endProgress(ofType: OperationFetchTags.key, message: "Done loading tags.", total: self.count)
            self.done()
        }
        
        db.add(operation)
    }
    
}

class DefaultProgressObserver : ProgressObserver {
    func startProgress(ofType key : String, message: String, size: Int) {
        
    }
    func updateProgress(ofType key : String, message: String, count: Int) {
        
    }
    func endProgress(ofType key : String, message: String, total: Int) {
        
    }
}
