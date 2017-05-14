//
//  OperationFetchWordPairs.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

//Deprecated

class OperationPagedWordPairs : BaseOperation {
    private let enfocaId : NSNumber?
    private let db : CKDatabase
    private(set) var count : Int = 0
    private let tags : [Tag]
    private let phrase : String?
    private(set) var cursor : CKQueryCursor?
    private(set) var wordPairs: [WordPair] = []
    private let sortDescriptor: NSSortDescriptor?
    
    private let maxResults : Int = 10
    
    
    init (tags : [Tag], phrase : String?, order : WordPairOrder, enfocaId: NSNumber, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = enfocaId
        self.db = db
        self.tags = tags
        self.phrase = phrase
        self.cursor = nil
        
        switch order {
        case .wordAsc:
            sortDescriptor = NSSortDescriptor(key: "word", ascending: true)
        case .wordDesc:
            sortDescriptor = NSSortDescriptor(key: "word", ascending: false)
        case .definitionAsc:
            sortDescriptor = NSSortDescriptor(key: "definition", ascending: true)
        case .definitionDesc:
            sortDescriptor = NSSortDescriptor(key: "definition", ascending: false)
        }
        
        super.init(errorDelegate: errorDelegate)
    }
    
    init (cursor: CKQueryCursor, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.enfocaId = nil
        self.db = db
        self.tags = []
        self.phrase = nil
        self.sortDescriptor = nil
        self.cursor = cursor
        super.init(errorDelegate: errorDelegate)
    }
    
    override func start() {
        super.start()
        
        if let _ = cursor {
            //If you have a cursor use it
            loadCloudDataWordPairs(referenceIds: nil, cursor: cursor, callback: { (cursor:CKQueryCursor) in
                self.cursor = cursor
            })
        } else if tags.count > 0 {
            //TODO! Filter for text too!!
            //If i'm tag filtering, do it
            loadDataWithFilter(with: tags, callback: { (cursor:CKQueryCursor) in
                self.cursor = cursor
            })
        } else {
            //Starting from nothing, no cursors and no filters
            loadCloudDataWordPairs(callback: { (cursor:CKQueryCursor) in
                self.cursor = cursor
            })
        }
        
    }
    
    fileprivate func loadDataWithFilter(with tags : [Tag], callback: @escaping (CKQueryCursor)->()){
        
        //CKRecordID's should be querried with CKReferences.
        let tagRefs : [CKReference] = tags.map { (tag: Tag) -> CKReference in
            guard let recordId = tag.tagId as? CKRecordID else {
                fatalError() //Someting is critically wrong
            }
            return CKReference(recordID: recordId, action: .none)
        }
        
        guard let enfocaId = enfocaId else { fatalError() } 
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@ AND tagRef in %@", enfocaId, tagRefs)
        let query: CKQuery = CKQuery(recordType: "TagAssociation", predicate: predicate)
        db.perform(query, inZoneWith: nil) { (records : [CKRecord]?, error : Error?) in
            if let error = error {
                self.handleError(error)
                return
            }
            
            guard let records = records, records.count > 0 else {
                print("Records is nil")
                self.handleError(message: "Records is nil")
                return
            }
            
            var referenceIds : [CKReference] = []
            for record in records {
                let wordRef = record.value(forKey: "wordRef") as! CKReference
                referenceIds.append(wordRef)
            }
            
            self.loadCloudDataWordPairs(referenceIds: referenceIds, cursor: nil, callback: callback)
        }
    }
    
    
    
    fileprivate func loadCloudDataWordPairs(referenceIds : [CKReference]? = nil, cursor : CKQueryCursor? = nil, callback: @escaping (CKQueryCursor)->()){
        
        //        https://developer.apple.com/reference/cloudkit/ckquery#//apple_ref/occ/cl/CKQuery
        //        http://stackoverflow.com/questions/32900235/how-to-query-cloudkit-for-recordid-in-ckrecordid
        
        
        let operation : CKQueryOperation
        
        wordPairs.removeAll()
        
        if let cursor = cursor {
            operation = CKQueryOperation(cursor: cursor)
        } else {
            guard let enfocaId = enfocaId else { fatalError() }
            guard let sort = sortDescriptor else { fatalError() }
            
            if let referenceIds = referenceIds {
                let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@ AND recordID IN %@", enfocaId, referenceIds)
                let query: CKQuery = CKQuery(recordType: "WordPair", predicate: predicate)
                query.sortDescriptors = [sort]
                operation = CKQueryOperation(query: query)
            } else {
                let predicate : NSPredicate = NSPredicate(format: "enfocaId == %@", enfocaId)
                let query: CKQuery = CKQuery(recordType: "WordPair", predicate: predicate)
                query.sortDescriptors = [sort]
                operation = CKQueryOperation(query: query)
            }
        }
        
        operation.resultsLimit = maxResults
        
        operation.recordFetchedBlock = {record in
            self.wordPairs.append(CloudKitConverters.toWordPair(from: record))
        }
        
        operation.queryCompletionBlock = {(cursor, error) in
            if let error = error {
                self.handleError(error)
                self.done()
                return
            }
            
            guard let cursor = cursor else {
                print("All records loaded")
                self.done()
                return
            }
            
            callback(cursor)
            self.done()
        }
        
        db.add(operation)
    }
}
