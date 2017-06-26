//
//  Dictionary.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class Dictionary {
    private(set) var definitionTitle: String
    private(set) var termTitle: String
    private(set) var subject: String
    private(set) var enfocaId: NSNumber

    init(enfocaId: NSNumber, termTitle: String, definitionTitle: String, subject: String) {
        self.definitionTitle = definitionTitle
        self.termTitle = termTitle
        self.subject = subject
        self.enfocaId = enfocaId
    }
    
//    public init (json: String) {
//    }
//    
//    public func toJson() -> String {
//    }
}
