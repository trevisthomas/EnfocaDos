//
//  Dictionary.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class UserDictionary {
    private(set) var definitionTitle: String
    private(set) var termTitle: String
    private(set) var subject: String
    private(set) var enfocaId: NSNumber
    private(set) var dictionaryId: String
    private(set) var userRef: String
    private(set) var language: String?
    
    private(set) var isTemporary: Bool = false
    

    init(dictionaryId: String, userRef: String, enfocaId: NSNumber, termTitle: String, definitionTitle: String, subject: String, language: String? = nil) {
        self.definitionTitle = definitionTitle
        self.termTitle = termTitle
        self.subject = subject
        self.enfocaId = enfocaId
        self.dictionaryId = dictionaryId
        self.userRef = userRef
        self.language = language
        
        isTemporary = false
    }
    
    convenience init(termTitle: String, definitionTitle: String, subject: String, language: String? = nil) {
        self.init(dictionaryId: "not-set", userRef: "not-set", enfocaId: NSNumber(integerLiteral: -1), termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
        isTemporary = true
    }
    
    func applyUpdate(termTitle: String, definitionTitle: String, subject : String, language: String?) {
        
        self.definitionTitle = definitionTitle
        self.termTitle = termTitle
        self.language = language
        self.subject = subject
    }
    
    convenience init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let id = jsonResult["dictionaryId"] as? String else {fatalError()}
        guard let userRef = jsonResult["userRef"] as? String else {fatalError()}
        guard let enfocaId = jsonResult["enfocaId"] as? NSNumber else {fatalError()}
        guard let termTitle = jsonResult["termTitle"] as? String else {fatalError()}
        guard let definitionTitle = jsonResult["definitionTitle"] as? String else {fatalError()}
        guard let subject = jsonResult["subject"] as? String else {fatalError()}
        let language = jsonResult["language"] as? String
        
        
        self.init(dictionaryId: id, userRef: userRef, enfocaId: enfocaId, termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language)
        
    }
    
    func toJson() -> String {
        var representation = [String: AnyObject]()
        
        
        representation["definitionTitle"] = definitionTitle as AnyObject?
        representation["termTitle"] = termTitle as AnyObject?
        representation["subject"] = subject as AnyObject?
        representation["enfocaId"] = enfocaId as AnyObject?
        representation["dictionaryId"] = dictionaryId as AnyObject?
        representation["userRef"] = userRef as AnyObject?
        representation["language"] = language as AnyObject?
        
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }}
