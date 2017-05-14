//
//  BaseUserOperation.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class BaseUserOperation : BaseCKOperation {
    let user : InternalUser
    
    init(user : InternalUser, db : CKDatabase, errorDelegate : ErrorDelegate){
        self.user = user
        super.init(db : db, errorDelegate: errorDelegate)
    }
}
