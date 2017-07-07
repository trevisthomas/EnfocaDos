//
//  CreateMetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class CreateMetaData{
    class func create(metaDataSource: MetaData, enfocaRef: CKReference) -> CKRecord {
        
        let ckWordPairId = CloudKitConverters.toCKRecordID(fromRecordName: metaDataSource.pairId)
        
        let wordPairRef = CKReference(recordID: ckWordPairId, action: .none)
        
        let record : CKRecord = CKRecord(recordType: "MetaData")
        
        record.setValue(metaDataSource.timedViewCount, forKey: "timedViewCount")
        record.setValue(metaDataSource.totalTime, forKey: "totalTime")
        record.setValue(metaDataSource.incorrectCount, forKey: "incorrectCount")
        record.setValue(metaDataSource.dateUpdated, forKey: "dateUpdated")
        record.setValue(metaDataSource.dateCreated, forKey: "dateCreated")
        record.setValue(wordPairRef, forKey: "wordRef")
        record.setValue(enfocaRef, forKey: "enfocaRef")
        
        return record
    }

}
