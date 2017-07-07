//
//  CreateTag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class CreateTag {
   
    class func create(tagName: String, enfocaRef: CKReference) -> CKRecord{
        let record : CKRecord = CKRecord(recordType: "Tag")
        record.setValue(tagName, forKey: "name")
        record.setValue(enfocaRef, forKey: "enfocaRef")
        
        return record
    }
}
