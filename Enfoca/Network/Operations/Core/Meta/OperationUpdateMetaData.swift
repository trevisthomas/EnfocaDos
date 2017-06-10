//
//  OperationUpdateMetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationUpdateMetaData : BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var metaData : MetaData?
    private let updatedMetaData : MetaData
    
    init (updatedMetaData: MetaData, enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        self.updatedMetaData = updatedMetaData
        super.init(errorDelegate: errorDelegate)
    }
    
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        let recordId = CKRecordID(recordName: updatedMetaData.metaId)
        
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
            
            let ckWordPairId = CloudKitConverters.toCKRecordID(fromRecordName: self.updatedMetaData.pairId)
            let wordPairRef = CKReference(recordID: ckWordPairId, action: .none)
            
            record.setValue(self.updatedMetaData.timedViewCount, forKey: "timedViewCount")
            record.setValue(self.updatedMetaData.totalTime, forKey: "totalTime")
            record.setValue(self.updatedMetaData.incorrectCount, forKey: "incorrectCount")
            record.setValue(self.updatedMetaData.dateUpdated, forKey: "dateUpdated")
            record.setValue(self.updatedMetaData.dateCreated, forKey: "dateCreated")
            record.setValue(wordPairRef, forKey: "wordRef")
            record.setValue(self.enfocaId, forKey: "enfocaId")
            
            self.db.save(record) { (newRecord: CKRecord?, error: Error?) in
                if let error = error {
                    self.handleError(error)
                }
                
                guard let newRecord = newRecord else {
                    self.done()
                    return
                }
                
                self.metaData = CloudKitConverters.toMetaData(from: newRecord)
                self.done()
            }
        }
    }
    
}
