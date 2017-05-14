//
//  BaseCKOperation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 2/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import CloudKit

class BaseCKOperation : BaseOperation {
    let db : CKDatabase
    init(db: CKDatabase, errorDelegate: ErrorDelegate) {
        self.db = db
        super.init(errorDelegate: errorDelegate)
    }
}
