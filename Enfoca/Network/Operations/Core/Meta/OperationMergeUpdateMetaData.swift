//
//  OperationMergeUpdateMetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/8/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

//This version just handles scores.  It loads the old record and merges your score.  This should make it so that quizzing on two devices at the same time will never step on old data
class OperationMergeUpdateMetaData : BaseOperation {
    private let db : CKDatabase
    private(set) var metaData : MetaData?
    private let oldMetaRecordID : CKRecordID
    private var isCorrect: Bool
    private var elapsedTime: Int
    
    init (oldMetaData: MetaData, isCorrect: Bool, elapsedTime: Int, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        self.isCorrect = isCorrect
        self.elapsedTime = elapsedTime
        self.oldMetaRecordID = CKRecordID(recordName: oldMetaData.metaId)
        super.init(errorDelegate: errorDelegate)
    }
    
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        db.fetch(withRecordID: oldMetaRecordID) { (record:CKRecord?, error:Error?) in
            
            guard let record = record else {
                if let error = error {
                    self.handleError(error)
                    self.done()
                    return
                } else {
                    fatalError() //?
                }
            }
            
            let updatedMetaData : MetaData = CloudKitConverters.toMetaData(from: record)
            
            updatedMetaData.updateScore(isCorrect: self.isCorrect, elapsedTime: self.elapsedTime)
            
            record.setValue(updatedMetaData.timedViewCount, forKey: "timedViewCount")
            record.setValue(updatedMetaData.totalTime, forKey: "totalTime")
            record.setValue(updatedMetaData.incorrectCount, forKey: "incorrectCount")
            record.setValue(updatedMetaData.dateUpdated, forKey: "dateUpdated")
            
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
