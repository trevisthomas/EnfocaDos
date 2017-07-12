//
//  Dictionary.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class UserDictionary: NSObject, NSCoding {
    private(set) var definitionTitle: String
    private(set) var termTitle: String
    private(set) var subject: String
    private(set) var dictionaryId: String
    private(set) var userRef: String
    private(set) var language: String?
    private(set) var enfocaRef: String
    private(set) var isTemporary: Bool = false
    
    private(set) var countWordPairs: Int = 0
    private(set) var countTags: Int = 0
    private(set) var countAssociations: Int = 0
    private(set) var countMeta: Int = 0
    
    var conch: String!
    
    init(dictionaryId: String, userRef: String, enfocaRef: String, termTitle: String, definitionTitle: String, subject: String, language: String? = nil, conch: String? = nil, countWordPairs: Int = 0, countTags: Int = 0, countAssociations: Int = 0, countMeta: Int = 0) {
        self.definitionTitle = definitionTitle
        self.termTitle = termTitle
        self.subject = subject
        self.enfocaRef = enfocaRef
        self.dictionaryId = dictionaryId
        self.userRef = userRef
        self.language = language
        self.conch = conch
        
        self.countWordPairs = countWordPairs
        self.countTags = countTags
        self.countAssociations = countAssociations
        self.countMeta = countMeta
        
        isTemporary = false
    }
    
    convenience init(termTitle: String, definitionTitle: String, subject: String, language: String? = nil) {
        self.init(dictionaryId: "not-set", userRef: "not-set", enfocaRef: "not-set", termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language, conch: "not-set")
        
        isTemporary = true
    }
    
    func applyUpdate(termTitle: String, definitionTitle: String, subject : String, language: String?) {
        
        self.definitionTitle = definitionTitle
        self.termTitle = termTitle
        self.language = language
        self.subject = subject
    }
    
    func applyCountUpdate(countWordPairs: Int, countAssociations: Int, countTags: Int, countMeta: Int) {
        self.countWordPairs = countWordPairs
        self.countAssociations = countAssociations
        self.countTags = countTags
        self.countMeta = countMeta
    }
    
    convenience init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let id = jsonResult["dictionaryId"] as? String else {fatalError()}
        guard let userRef = jsonResult["userRef"] as? String else {fatalError()}
        guard let enfocaRef = jsonResult["enfocaRef"] as? String else {fatalError()}
        guard let termTitle = jsonResult["termTitle"] as? String else {fatalError()}
        guard let conch = jsonResult["conch"] as? String else {fatalError()}
        
        guard let definitionTitle = jsonResult["definitionTitle"] as? String else {fatalError()}
        guard let subject = jsonResult["subject"] as? String else {fatalError()}
        let language = jsonResult["language"] as? String
        
        
        
        self.init(dictionaryId: id, userRef: userRef, enfocaRef: enfocaRef, termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language, conch: conch)
        
        if let countWordPairs = jsonResult["countWordPairs"] as? Int {
            self.countWordPairs = countWordPairs
        }
        
        if let countAssociations = jsonResult["countAssociations"] as? Int {
            self.countAssociations = countAssociations
        }
        
        if let countTags = jsonResult["countTags"] as? Int {
            self.countTags = countTags
        }
        
        if let countMeta = jsonResult["countMeta"] as? Int {
            self.countMeta = countMeta
        }
        
        
        
    }
    
    func toJson() -> String {
        var representation = [String: AnyObject]()
        
        
        representation["definitionTitle"] = definitionTitle as AnyObject?
        representation["termTitle"] = termTitle as AnyObject?
        representation["subject"] = subject as AnyObject?
        representation["enfocaRef"] = enfocaRef as AnyObject?
        representation["dictionaryId"] = dictionaryId as AnyObject?
        representation["userRef"] = userRef as AnyObject?
        representation["language"] = language as AnyObject?
        representation["conch"] = conch as AnyObject?
        
        representation["countWordPairs"] = countWordPairs as AnyObject?
        representation["countAssociations"] = countAssociations as AnyObject?
        representation["countTags"] = countTags as AnyObject?
        representation["countMeta"] = countMeta as AnyObject?
        
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        
        guard let id = aDecoder.decodeObject(forKey:"dictionaryId") as? String else {fatalError()}
        guard let userRef = aDecoder.decodeObject(forKey:"userRef") as? String else {fatalError()}
        guard let enfocaRef = aDecoder.decodeObject(forKey:"enfocaRef") as? String else {fatalError()}
        guard let termTitle = aDecoder.decodeObject(forKey:"termTitle") as? String else {fatalError()}
        guard let conch = aDecoder.decodeObject(forKey:"conch") as? String else {fatalError()}
        
        guard let definitionTitle = aDecoder.decodeObject(forKey:"definitionTitle") as? String else {fatalError()}
        guard let subject = aDecoder.decodeObject(forKey:"subject") as? String else {fatalError()}
        let language = aDecoder.decodeObject(forKey:"language") as? String
        
        self.init(dictionaryId: id, userRef: userRef, enfocaRef: enfocaRef, termTitle: termTitle, definitionTitle: definitionTitle, subject: subject, language: language, conch: conch)
        
        self.countWordPairs = aDecoder.decodeInteger(forKey:"countWordPairs")
        self.countAssociations = aDecoder.decodeInteger(forKey:"countAssociations")
        self.countTags = aDecoder.decodeInteger(forKey:"countTags")
        self.countMeta = aDecoder.decodeInteger(forKey:"countMeta")
        
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(definitionTitle, forKey: "definitionTitle")
        aCoder.encode(termTitle, forKey: "termTitle")
        aCoder.encode(subject, forKey: "subject")
        aCoder.encode(enfocaRef, forKey: "enfocaRef")
        aCoder.encode(dictionaryId, forKey: "dictionaryId")
        aCoder.encode(userRef, forKey: "userRef")
        aCoder.encode(language, forKey: "language")
        aCoder.encode(conch, forKey: "conch")
        
        aCoder.encode(countWordPairs, forKey: "countWordPairs")
        aCoder.encode(countAssociations, forKey: "countAssociations")
        aCoder.encode(countTags, forKey: "countTags")
        aCoder.encode(countMeta, forKey: "countMeta")
        
    }
    
}


