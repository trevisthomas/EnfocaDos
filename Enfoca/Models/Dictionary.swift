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
    private(set) var dictionaryId: String
    private(set) var userRef: String
    private(set) var language: String?
    

    init(dictionaryId: String, userRef: String, enfocaId: NSNumber, termTitle: String, definitionTitle: String, subject: String, language: String? = nil) {
        self.definitionTitle = definitionTitle
        self.termTitle = termTitle
        self.subject = subject
        self.enfocaId = enfocaId
        self.dictionaryId = dictionaryId
        self.userRef = userRef
        self.language = language
    }
    
    convenience init(termTitle: String, definitionTitle: String, subject: String, language: String? = nil) {
        self.init(dictionaryId: "not-set", userRef: "not-set", enfocaId: NSNumber(integerLiteral: -1), termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
    }
    
//    public init (json: String) {
//    }
//    
//    public func toJson() -> String {
//    }
}
