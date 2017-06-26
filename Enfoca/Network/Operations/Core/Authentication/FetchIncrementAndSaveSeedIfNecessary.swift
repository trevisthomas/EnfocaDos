//
//  FetchIncrementAndSaveSeed.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit


//TODO errors in this class needs some thought
class FetchIncrementAndSaveSeedIfNecessary : BaseUserOperation {
    
    override func start() {
        state = .inProgress
        
        if isCancelled {
            done()
            return
        }
        
        if let _ = user.record.value(forKey: "enfocaId") as? Int {
            //If he has an enfoca id, then incrementing the seed is not necessary
            done()
            return
        }
        
        //Trevis! TODO: What does this mean in production?
        
//        let settingsId = CKRecordID(recordName: "9ea8a03a-9867-4365-8ece-94380971bc13")
        let settingsId = CKRecordID(recordName: "900682b2-f02d-4239-9640-b3566c04bdc8")
        
        db.fetch(withRecordID: settingsId, completionHandler: { (record: CKRecord?, error: Error?) in
            guard let id = record?.value(forKey: "Seed") as? Int, let record = record else {
                //Settings record doesnt exist
//                self.done()
//                return
                fatalError()
            }
            let enfocaId = id + 1
            record.setValue(enfocaId, forKey: "Seed")
            self.db.save(record, completionHandler: { (record:CKRecord?, error:Error?) in
                if let error = error {
                    print(error)
                    fatalError() //Handle error.  Here is where we'd end up if the error record was updated while you were updating it
                } else {
                    self.user.newEnfocaId = enfocaId
                }
                
                self.done()
            })
        })
    }
    
}
