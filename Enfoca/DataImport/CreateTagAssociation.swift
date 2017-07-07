//
//  CreateTagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/6/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class CreateTagAssociation {
    class func create(tagId: String, wordPairId: String, enfocaRef: CKReference) -> CKRecord{
        let record : CKRecord = CKRecord(recordType: "TagAssociation")
        
        let ckTagId = CloudKitConverters.toCKRecordID(fromRecordName: tagId)
        let ckWordPairId = CloudKitConverters.toCKRecordID(fromRecordName: wordPairId)
        
        let tagRef = CKReference(recordID: ckTagId, action: .none)
        let wpRef = CKReference(recordID: ckWordPairId, action: .none)
        
        record.setValue(wpRef, forKey: "wordRef")
        record.setValue(tagRef, forKey: "tagRef")
        record.setValue(enfocaRef, forKey: "enfocaRef")

        return record
    }
}
