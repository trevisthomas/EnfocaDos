//
//  CreateWordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/6/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class CreateWordPair {
//    private let enfocaRef : CKReference
//    private let db : CKDatabase
//    private(set) var wordPair : WordPair?
//    private let wordPairSource : WordPair
    
    class func create (wordPairSource: WordPair, enfocaRef : CKReference) -> CKRecord {
        
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
        
        return record
        
//        db.save(record) { (newRecord: CKRecord?, error: Error?) in
//            if let error = error {
//                print(error)
//                CreateWordPair.save(wordPairSource: wordPairSource, enfocaRef : enfocaRef, db: db, callback: callback)
//            }
//            
//            guard let newRecord = newRecord else {
//                print("retry wordpair \(wordPairSource.word)")
//                CreateWordPair.save(wordPairSource: wordPairSource, enfocaRef : enfocaRef, db: db, callback: callback)
//                return
//            }
//            
//            callback(CloudKitConverters.toWordPair(from: newRecord))
//        }
    }
}
