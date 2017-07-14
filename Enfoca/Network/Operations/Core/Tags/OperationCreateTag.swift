//
//  OperationCreateTag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationCreateTag : BaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var tag : Tag?
    private let fromTag : Tag
    
    init (fromTag: Tag, enfocaRef: CKReference, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.fromTag = fromTag
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        let record : CKRecord = CKRecord(recordType: "Tag")
        record.setValue(fromTag.name, forKey: "name")
        if let color = fromTag.color {
            record.setValue(color, forKey: "color")
        }
        record.setValue(enfocaRef, forKey: "enfocaRef")
        
        db.save(record) { (newRecord: CKRecord?, error: Error?) in
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
