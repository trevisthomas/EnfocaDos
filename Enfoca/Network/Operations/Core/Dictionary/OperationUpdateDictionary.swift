//
//  OperationUpdateDictionary.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationUpdateDictionary : BaseOperation {
    private let db : CKDatabase
    private(set) var dictionary : UserDictionary?
    private let updatedDictionary : UserDictionary
    
    init (updatedDictionary: UserDictionary, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        self.updatedDictionary = updatedDictionary
        super.init(errorDelegate: errorDelegate)
    }
    
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        let recordId = CKRecordID(recordName: updatedDictionary.dictionaryId)
        
        db.fetch(withRecordID: recordId) { (record:CKRecord?, error:Error?) in
            
            guard let record = record else {
                if let error = error {
                    self.handleError(error)
                    self.done()
                    return
                } else {
                    fatalError() //?
                }
            }
            
            record.setValue(self.updatedDictionary.definitionTitle, forKey: "definitionTitle")
            record.setValue(self.updatedDictionary.termTitle, forKey: "termTitle")
            record.setValue(self.updatedDictionary.subject, forKey: "subject")
            if let _ = self.updatedDictionary.language  {
                record.setValue(self.updatedDictionary.language, forKey: "language")
            }
            
            self.db.save(record) { (newRecord: CKRecord?, error: Error?) in
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
}
