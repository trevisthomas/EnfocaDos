//
//  OldWordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OldWordPair {
    var ckPairid: CKRecordID?
    var studyItemId : String
    var creationDate : Date
    var word: String
    var definition: String
    var example: String?
    
    var newWordPair: WordPair?
    
    
    init(studyItemId : String, creationDate : Date, word: String, definition: String, example: String?){
        self.studyItemId = studyItemId
        self.creationDate = creationDate
        self.word = word
        self.definition = definition
        self.example = example
    }
}
