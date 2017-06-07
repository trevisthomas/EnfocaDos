//
//  OldTag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OldTag {
    var tagId : String
    var ckTagId : CKRecordID!
    var tagName : String
    
    var newTag : Tag?
    
    init(tagId: String, tagName: String) {
        self.tagId = tagId
        self.tagName = tagName
    }
    
    var description: String {
        return "Tag: \(tagId):\(tagName)"
    }
}
