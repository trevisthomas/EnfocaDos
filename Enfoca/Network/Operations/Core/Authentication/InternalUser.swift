//
//  User.swift
//  CloudData
//
//  Created by Trevis Thomas on 1/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class InternalUser {
    var enfocaId : Int!
    var totalPairs : Int?
    var newEnfocaId : Int!
    var recordId : CKRecordID!
    var record : CKRecord!
    var isAuthenticated: Bool = false
}
