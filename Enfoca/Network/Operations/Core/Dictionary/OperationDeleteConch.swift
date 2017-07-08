//
//  OperationDeleteConch.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/8/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationDeleteConch : BaseOperation {
    private let db : CKDatabase
    private(set) var conch : String?
    private let enfocaRef: CKReference
    
    init (enfocaRef: CKReference, db: CKDatabase, errorDelegate : ErrorDelegate) {
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
            
            if records.count == 0 {
                //Shouldnt happen in prod, but if so who cares.
                self.done()
                return
            }
            
            let record = records[0]
            
            self.db.delete(withRecordID: record.recordID) { (recordId:CKRecordID?, error:Error?) in
                if let error = error {
                    self.handleError(error)
                }
                if let _ = recordId {
                    self.conch = CloudKitConverters.toConch(record: record)
                }
                self.done()
            }
            
        }
    }
}
