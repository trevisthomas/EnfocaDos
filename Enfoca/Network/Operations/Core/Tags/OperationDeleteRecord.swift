//
//  OperationDeleteRecord.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/19/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationDeleteRecord: BaseOperation {
    private let db : CKDatabase
    private(set) var recordName: String
    private(set) var deletedRecordName: String?
    
    init (recordName: String, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        self.recordName = recordName
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        let recordId = CloudKitConverters.toCKRecordID(fromRecordName: recordName)
        
        db.delete(withRecordID: recordId) { (recordId:CKRecordID?, error:Error?) in
            if let error = error {
                self.handleError(error)
            }
            if let recordId = recordId {
                self.deletedRecordName = recordId.recordName
            }
            self.done()
        }
    }
}
