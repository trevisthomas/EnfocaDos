//
//  OldMetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OldMetaData {
    var ckMetaId: CKRecordID?
    var ckPairid: CKRecordID?
    var studyItemId: String
    var creationDate: Date
    var incorrectCount: Int
//    var viewCount: Int  //According to a comment in the old code, i kept both of these because at some point i added tracking timing.  It wasnt always there.  But i think that i'm just going to reset this data in the new mobile enfoca
    var lastUpdate: Date?
    var totalTime: Int
    var timedViewCount: Int
    
    init(studyItemId : String, creationDate : Date, incorrectCount: Int, lastUpdate: Date?, totalTime: Int, timedViewCount: Int){
        self.studyItemId = studyItemId
        self.creationDate = creationDate
        self.incorrectCount = incorrectCount
        self.lastUpdate = lastUpdate
        self.totalTime = totalTime
        self.timedViewCount = timedViewCount
    }
}

