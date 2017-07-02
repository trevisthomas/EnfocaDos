//
//  OperationUpdateConch.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

import CloudKit

class OperationResetConch : BaseOperation {
    private let db : CKDatabase
    private(set) var conch : String?
    private(set) var isNew: Bool = false
    private let enfocaRef: CKReference
    
    init (enfocaRef: CKReference, db: CKDatabase, errorDelegate : ErrorDelegate) {
        self.db = db
        self.enfocaRef = enfocaRef
        super.init(errorDelegate: errorDelegate)
        
    }
    
    override func start() {
        super.start()
        
        if isCancelled {
            self.done()
            return
        }
        
        let predicate : NSPredicate = NSPredicate(format: "enfocaRef == %@", enfocaRef)
        
        let query: CKQuery = CKQuery(recordType: "Synch", predicate: predicate)
        
        db.perform(query, inZoneWith: nil) { (records: [CKRecord]?, error: Error?) in
            if let error = error {
                self.handleError(error)
                self.done()
                return
            }
            
            guard let records = records else { fatalError() }
            
            if records.count != 1 {
                fatalError()
            }
            
            let record = records[0]
            
            let uuid = UUID().uuidString
            record.setValue(uuid, forKey: "conch")
            
            self.db.save(record) { (updatedRecord: CKRecord?, error: Error?) in
                if let error = error {
                    self.handleError(error)
                }
                
                guard let _ = updatedRecord else {
                    //This shouldnt happen, but there is nothing that the user can do about it if it does... 
                    fatalError()
                }
                //DO NOT store the new conch locally.  The whole point here is that you are out of synch, but are being allowed to make data changes on a case by case basis.  To get out of that state, you need to reload the DB, reloading will update your local conch.
                //self.conch = CloudKitConverters.toConch(record: updatedRecord)
                self.done()
            }
        }
    }
}
