//
//  OperationCreateDictionary.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationCreateDictionary : BaseOperation {
    private(set) var dictionary : UserDictionary?
    private let dictionarySource : UserDictionary
    private let db: CKDatabase
    private let ckUserRecordId: CKRecordID
    
    
    init (dictionarySource: UserDictionary,  db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.dictionarySource = dictionarySource
        
        self.db = db
        
        ckUserRecordId = CloudKitConverters.toCKRecordID(fromRecordName: self.dictionarySource.userRef)
        
        
        super.init( errorDelegate: errorDelegate)
        
    }
    
    override func start() {
        super.start()
        
        //Hm, should you let this auto delete if the user is removed? Seems like an edge case but...
        let userReference = CKReference(recordID: ckUserRecordId, action: .none)
        
        let record : CKRecord = CKRecord(recordType: "Dictionary")
        
        let enfocaRef = CKReference(recordID: record.recordID, action: .none)
        
        record.setValue(dictionarySource.definitionTitle, forKey: "definitionTitle")
        record.setValue(dictionarySource.termTitle, forKey: "termTitle")
        record.setValue(dictionarySource.subject, forKey: "subject")
        record.setValue(userReference, forKey: "userRef")
        record.setValue(0, forKey: "count")
        record.setValue(enfocaRef, forKey: "enfocaRef")
        
        if let _ = dictionarySource.language  {
            record.setValue(dictionarySource.language, forKey: "language")
        }
        
        db.save(record) { (newRecord: CKRecord?, error: Error?) in
            if let error = error {
                self.handleError(error)
            }
            
            guard let newRecord = newRecord else {
                self.done()
                return
            }
            
            self.dictionary = CloudKitConverters.toDictionary(from: newRecord)
            self.done()
        }
    }
}
