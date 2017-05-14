//
//  OperationCountWordPairs.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

//Deprecated


class OperationCountWordPairs : BaseOperation {
    private let enfocaId : NSNumber
    private let db : CKDatabase
    private(set) var count : Int = 0
    private let tags : [Tag]
    private let phrase : String?
    
    
    init (tags : [Tag], phrase : String?, enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        self.tags = tags
        self.phrase = phrase
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        //CKRecordID's should be querried with CKReferences.
        let tagRefs : [CKReference] = tags.map { (tag: Tag) -> CKReference in
            guard let recordId = tag.tagId as? CKRecordID else {
                fatalError() //Someting is critically wrong
            }
            return CKReference(recordID: recordId, action: .none)
        }
        
        let predicate : NSPredicate
        let query : CKQuery
        if(tags.count > 0){
            predicate = NSPredicate(format: "enfocaId == %@ AND TagRef in %@", enfocaId, tagRefs)
            query = CKQuery(recordType: "TagAssociations", predicate: predicate)
        } else {
            predicate = NSPredicate(format: "enfocaId == %@", enfocaId)
            query = CKQuery(recordType: "WordPair", predicate: predicate)
        }
        
        performQuery(operation: CKQueryOperation(query: query))
    }
    
    func performQuery(operation op : CKQueryOperation){
        op.desiredKeys = [] //TREVIS! Passing an empty string seems to do what you want it to!
        
        op.recordFetchedBlock = { (record : CKRecord) in
            //            print("tags: \(record.allKeys())")
            self.count += 1
        }
        
        op.queryCompletionBlock = {(cursor : CKQueryCursor?, error : Error?) in
            if let error = error {
                self.handleError(error)
                self.done()
            }
            
            if let cursor = cursor {
                //more data
                self.performQuery(operation: CKQueryOperation(cursor: cursor))
            } else {
                self.done()
            }
        }
        
        db.add(op)
    }
    
}
