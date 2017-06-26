//
//  CloudKitConverters.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitConverters{
    class func toTag(from record: CKRecord) -> Tag {
        guard let name = record.value(forKey: "name") as? String else {
            //This is really bad.  Should probably delete this record
            fatalError()
        }
        
        let t = Tag(tagId: record.recordID.recordName, name: name)
        return t
    }
    
    class func toWordPair(from record : CKRecord) -> WordPair {
        guard let word = record.value(forKey: "word") as? String else { fatalError() }
        
        guard let definition = record.value(forKey: "definition") as? String else { fatalError() }
        
        guard let dateCreated = record.value(forKey: "dateCreated") as? Date else { fatalError() }
        
        let gender : Gender
        if let g = record.value(forKey: "gender") as? String {
            gender = Gender.fromString(g)
        } else {
            gender = .notset
        }
        
        let example = record.value(forKey: "example") as? String
        
        return WordPair(pairId: record.recordID.recordName, word: word, definition: definition, dateCreated: dateCreated, gender: gender, tags: [], example: example)
    }
    
    class func toTagAssociation(from record : CKRecord) -> TagAssociation {
        guard let tagRef = record.value(forKey: "tagRef") as? CKReference else {
            fatalError()
        }
        
        guard let wordRef = record.value(forKey: "wordRef") as? CKReference else {
            fatalError()
        }
        
        let ass = TagAssociation(associationId: record.recordID.recordName,
                                 wordPairId: wordRef.recordID.recordName,
                                 tagId: tagRef.recordID.recordName)
        
        return ass
    }
    
    class func toMetaData(from record : CKRecord) -> MetaData {
        
        guard let dateCreated = record.value(forKey: "dateCreated") as? Date else { fatalError() }
        
        let dateUpdated = record.value(forKey: "dateUpdated") as? Date
        
        guard let incorrectCount = record.value(forKey: "incorrectCount") as? Int else { fatalError() }
        guard let totalTime = record.value(forKey: "totalTime") as? Int else { fatalError() }
        guard let timedViewCount = record.value(forKey: "timedViewCount") as? Int else { fatalError() }
        
        guard let wordRef = record.value(forKey: "wordRef") as? CKReference else {
            fatalError()
        }
        
        let meta = MetaData(metaId: record.recordID.recordName, pairId: wordRef.recordID.recordName, dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: incorrectCount, totalTime: totalTime, timedViewCount: timedViewCount)
        
        return meta

    }
    
    class func toCKRecordID(fromRecordName name: String) -> CKRecordID{
        return CKRecordID(recordName: name)
        
    }
    
    class func toDictionary(from record: CKRecord) -> Dictionary {
        guard let definitionTitle = record.value(forKey: "definitionTitle") as? String else { fatalError() }
        guard let termTitle = record.value(forKey: "termTitle") as? String else { fatalError() }
        guard let subject = record.value(forKey: "subject") as? String else { fatalError() }
        guard let enfocaId = record.value(forKey: "enfocaId") as? NSNumber else { fatalError() }
       
        guard let userRef = record.value(forKey: "userRef") as? CKReference else {
            fatalError()
        }
        
        guard let language = record.value(forKey: "language") as? String else { fatalError() }
        
        let dict = Dictionary(dictionaryId: record.recordID.recordName, userRef: userRef.recordID.recordName, enfocaId: enfocaId, termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
        return dict 
    }
}
