//
//  OperationUpdateWordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/19/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationUpdateWordPair : BaseOperation {
    private let db : CKDatabase
    private(set) var wordPair : WordPair?
    private let tempWordPair : WordPair
    
    init (updatedWordPair: WordPair, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        self.tempWordPair = updatedWordPair
        super.init(errorDelegate: errorDelegate)
    }
    
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        let recordId = CKRecordID(recordName: tempWordPair.pairId)
        
        db.fetch(withRecordID: recordId) { (record:CKRecord?, error:Error?) in
            
            guard let record = record else {
                if let error = error {
                    self.handleError(error)
                    self.done()
                    return
                } else {
                    fatalError() //?
                }
            }
            
            record.setValue(self.tempWordPair.word, forKey: "word")
            record.setValue(self.tempWordPair.definition, forKey: "definition")
            record.setValue(self.tempWordPair.dateCreated, forKey: "dateCreated")
            record.setValue(self.tempWordPair.gender.toString(), forKey: "gender")
            if let example = self.tempWordPair.example {
                record.setValue(example, forKey: "example")
            }
            
            self.db.save(record) { (newRecord: CKRecord?, error: Error?) in
                if let error = error {
                    self.handleError(error)
                }
                
                guard let newRecord = newRecord else {
                    self.done()
                    return
                }
                
                self.wordPair = CloudKitConverters.toWordPair(from: newRecord)
                self.done()
            }
        }
    }
    
}
