//
//  OperationTagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationCreateTagAssociation: BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var tagId : String
    private(set) var wordPairId : String
    private(set) var tagAssociation: TagAssociation?
    
    
    init (tagId: String, wordPairId: String, enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        self.wordPairId = wordPairId
        self.tagId = tagId
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        let record : CKRecord = CKRecord(recordType: "TagAssociation")
        
        let ckTagId = CloudKitConverters.toCKRecordID(fromRecordName: tagId)
        let ckWordPairId = CloudKitConverters.toCKRecordID(fromRecordName: wordPairId)
        
        let tagRef = CKReference(recordID: ckTagId, action: .none)
        let wpRef = CKReference(recordID: ckWordPairId, action: .none)
        
        record.setValue(wpRef, forKey: "wordRef")
        record.setValue(tagRef, forKey: "tagRef")
        record.setValue(enfocaId, forKey: "enfocaId")
        
        db.save(record) { (newRecord: CKRecord?, error: Error?) in
            if let error = error {
                self.handleError(error)
            }
            
            guard let newRecord = newRecord else {
                self.done()
                return
            }
            
            self.tagAssociation = CloudKitConverters.toTagAssociation(from: newRecord)
            self.done()
        }
        
    }
}
