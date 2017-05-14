//
//  CreateEnfocaId.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class FetchOrCreateEnfocaId : BaseUserOperation {
    
    override func start() {
        state = .inProgress
        
        if isCancelled {
            done()
            return
        }
        
        if let id = user.record.value(forKey: "enfocaId") as? Int {
            user.enfocaId = id
            done()
            return
        }
        
        guard let id = user.newEnfocaId else {
            fatalError() //Precondition not met
        }
        
        user.record.setValue(id, forKey: "enfocaId")
        db.save(user.record, completionHandler: { (record:CKRecord?, error:Error?) in
            if let error = error {
                self.handleError(error)
//                fatalError() //Failed to update.   What to do!?
            } else {
                self.user.enfocaId = id
            }
            self.done()
        })
    }
}
