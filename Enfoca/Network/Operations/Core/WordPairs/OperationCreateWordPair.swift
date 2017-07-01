//
//  OperationCreateWordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class OperationCreateWordPair : BaseOperation {
    private let enfocaRef : CKReference
    private let db : CKDatabase
    private(set) var wordPair : WordPair?
    private let wordPairSource : WordPair
    
    init (wordPairSource: WordPair, enfocaRef : CKReference, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaRef = enfocaRef
        self.db = db
        self.wordPairSource = wordPairSource
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()

        let record : CKRecord = CKRecord(recordType: "WordPair")
        record.setValue(wordPairSource.word, forKey: "word")
        record.setValue(wordPairSource.definition, forKey: "definition")
        record.setValue(wordPairSource.dateCreated, forKey: "dateCreated")
        
        if let example = wordPairSource.example {
            record.setValue(example, forKey: "example")
        }
        
        if(wordPairSource.gender != .notset) {
            record.setValue(wordPairSource.gender.toString(), forKey: "gender")
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
            
            self.wordPair = CloudKitConverters.toWordPair(from: newRecord)
            self.done()
        }
    }
}
