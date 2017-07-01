//
//  File.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationCreateMetaData : BaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var metaData : MetaData?
    private let metaDataSource : MetaData
    
    init (metaDataSource: MetaData, enfocaRef: CKReference, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.metaDataSource = metaDataSource
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        let ckWordPairId = CloudKitConverters.toCKRecordID(fromRecordName: metaDataSource.pairId)
//        let wordPairRef = CKReference(recordID: ckWordPairId, action: .deleteSelf) //Wont work accross zones
        let wordPairRef = CKReference(recordID: ckWordPairId, action: .none)
        
        let record : CKRecord = CKRecord(recordType: "MetaData")
        
        record.setValue(metaDataSource.timedViewCount, forKey: "timedViewCount")
        record.setValue(metaDataSource.totalTime, forKey: "totalTime")
        record.setValue(metaDataSource.incorrectCount, forKey: "incorrectCount")
        record.setValue(metaDataSource.dateUpdated, forKey: "dateUpdated")
        record.setValue(metaDataSource.dateCreated, forKey: "dateCreated")
        record.setValue(wordPairRef, forKey: "wordRef")
        record.setValue(enfocaRef, forKey: "enfocaRef")
        
        db.save(record) { (newRecord: CKRecord?, error: Error?) in
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
