//
//  OldTagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OldTagAssociation{
    var tagId: String
    var studyItemId: String
    var ckTagId : CKRecordID?
    var ckPairId : CKRecordID?
    
    init(tagId : String, studyItemId: String){
        self.tagId = tagId
        self.studyItemId = studyItemId
    }
}
