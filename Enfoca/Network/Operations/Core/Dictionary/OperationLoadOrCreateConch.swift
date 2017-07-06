//
//  OperationLoadOrCreateConch.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import CloudKit

class OperationLoadOrCreateConch : BaseOperation {
    private let db : CKDatabase
    private(set) var conch : String?
    private(set) var isNew: Bool = false
    private let enfocaRef: CKReference
    private let allowCreation: Bool
    
    init (enfocaRef: CKReference, db: CKDatabase, allowCreation: Bool, errorDelegate : ErrorDelegate) {
        self.allowCreation = allowCreation
        self.db = db
        self.enfocaRef = enfocaRef
        super.init(errorDelegate: errorDelegate)
        
    }
    
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let query: CKQuery = CKQuery(recordType: "Synch", predicate: predicate)
        
        db.perform(query, inZoneWith: nil) { (records: [CKRecord]?, error: Error?) in
            if let error = error {
                self.handleError(error)
                self.done()
                return
            }
            
            guard let records = records else { fatalError() }
            
            
            if records.count >= 1 { //Should be equal to 1
                let record = records[0]
                self.conch = CloudKitConverters.toConch(record: record)
                self.done()
            } else {
                if self.allowCreation == false {
                    self.conch = nil
                    self.handleError(message: "Synchronization conch does not exist, but allowCreation is set to false.")
                    self.done()
                }
                
                let newRecord = CKRecord(recordType: "Synch")
                
                let uuid = UUID().uuidString
                newRecord.setValue(self.enfocaRef, forKey: "enfocaRef")
                newRecord.setValue(uuid, forKey: "conch")
                self.isNew = true
                
                self.db.save(newRecord) { (newRecord: CKRecord?, error: Error?) in
                    if let error = error {
                        self.handleError(error)
                    }
                    
                    guard let newRecord = newRecord else {
                        self.done()
                        return
                    }
                    
                    self.conch = CloudKitConverters.toConch(record: newRecord)
                    self.done()
                }
                
            }
            
            
        }
    }
    
    
}
