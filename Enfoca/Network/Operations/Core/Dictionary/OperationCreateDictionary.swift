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
    private var enfocaCkRef: CKReference!
    
    
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
        
        enfocaCkRef = CKReference(recordID: record.recordID, action: .none)
        
        record.setValue(dictionarySource.definitionTitle, forKey: "definitionTitle")
        record.setValue(dictionarySource.termTitle, forKey: "termTitle")
        record.setValue(dictionarySource.subject, forKey: "subject")
        
        record.setValue(userReference, forKey: "userRef")
        
        record.setValue(0, forKey: "countWordPairs")
        record.setValue(0, forKey: "countTags")
        record.setValue(0, forKey: "countAssociations")
        record.setValue(0, forKey: "countMeta")
        
        record.setValue(enfocaCkRef, forKey: "enfocaRef")
        
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
//            self.createConch(callback: { (conch: String) in
//                self.dictionary?.conch = conch
//                self.done()
//            })
        }
    }
    
// I backed off on this idea
//    func createConch(callback: @escaping (String)->()) {
//        let newRecord = CKRecord(recordType: "Synch")
//        
//        let uuid = UUID().uuidString
//        newRecord.setValue(enfocaCkRef, forKey: "enfocaRef")
//        newRecord.setValue(uuid, forKey: "conch")
//        
//        
//        self.db.save(newRecord) { (newRecord: CKRecord?, error: Error?) in
//            if let error = error {
//                self.handleError(error)
//            }
//            
//            guard let newRecord = newRecord else {
//                self.handleError(message: "conch was nil")
//                return
//            }
//            
//            let conch = CloudKitConverters.toConch(record: newRecord)
//            callback(conch)
//        }
//    }
}
