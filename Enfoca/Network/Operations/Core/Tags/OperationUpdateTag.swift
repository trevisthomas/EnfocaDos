//
//  OperationUpdateTag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/19/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationUpdateTag : BaseOperation {
    private let db : CKDatabase
    private(set) var tag : Tag?
    private let updatedTag : Tag
    
    init (updatedTag: Tag, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        self.updatedTag = updatedTag
        super.init(errorDelegate: errorDelegate)
    }
    
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        let recordId = CKRecordID(recordName: updatedTag.tagId)
        
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
            
            record.setValue(self.updatedTag.name, forKey: "name")
            
            self.db.save(record) { (newRecord: CKRecord?, error: Error?) in
                if let error = error {
                    self.handleError(error)
                }
                
                guard let newRecord = newRecord else {
                    self.done()
                    return
                }
                
                self.tag = CloudKitConverters.toTag(from: newRecord)
                self.done()
            }
        }
    }
    
}
