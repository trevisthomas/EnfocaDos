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
    private(set) var dictionary : Dictionary?
    private let dictionarySource : Dictionary
    private let db: CKDatabase
    private let enfocaIdProvider: EnfocaIdProvider
    private let ckUserRecordId: CKRecordID
    
    
    init (enfocaIdProvider: EnfocaIdProvider, dictionarySource: Dictionary,  db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.dictionarySource = dictionarySource
        
        self.enfocaIdProvider = enfocaIdProvider
        self.db = db
        
        ckUserRecordId = CloudKitConverters.toCKRecordID(fromRecordName: self.dictionarySource.userRef)
        
        
        super.init( errorDelegate: errorDelegate)
        
    }
    
    override func start() {
        super.start()
        
        //Hm, should you let this auto delete if the user is removed? Seems like an edge case but...
        let userReference = CKReference(recordID: ckUserRecordId, action: .none)
        
        let record : CKRecord = CKRecord(recordType: "Dictionary")
        record.setValue(dictionarySource.definitionTitle, forKey: "definitionTitle")
        record.setValue(dictionarySource.termTitle, forKey: "termTitle")
        record.setValue(dictionarySource.subject, forKey: "subject")
        record.setValue(userReference, forKey: "userRef")
        
        if let _ = dictionarySource.language  {
            record.setValue(dictionarySource.language, forKey: "language")
        }
        
        guard let enfocaId = enfocaIdProvider.enfocaId else { fatalError() }
        
        record.setValue(enfocaId, forKey: "enfocaId")
        
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
