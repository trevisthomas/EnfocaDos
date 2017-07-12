//
//  TagAssociation.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/28/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class TagAssociation: NSObject, NSCoding {
    private(set) var associationId : String
    private(set) var wordPairId : String
    private(set) var tagId : String
    
    init (associationId: String, wordPairId: String, tagId : String) {
        self.wordPairId = wordPairId
        self.tagId = tagId
        self.associationId = associationId
    }
    
    public init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let wordPairId = jsonResult["wordPairId"] as? String else {fatalError()}
        guard let tagId = jsonResult["tagId"] as? String else {fatalError()}
        guard let associationId = jsonResult["associationId"] as? String else {fatalError()}
        
        self.wordPairId = wordPairId
        self.tagId = tagId
        self.associationId = associationId
        
    }
    
    func toJson() -> String {
        var representation = [String: AnyObject]()
        representation["wordPairId"] = wordPairId as AnyObject?
        representation["tagId"] = tagId as AnyObject?
        representation["associationId"] = associationId as AnyObject?
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        guard let wordPairId = aDecoder.decodeObject(forKey:"wordPairId") as? String else {fatalError()}
        guard let tagId = aDecoder.decodeObject(forKey:"tagId") as? String else {fatalError()}
        guard let associationId = aDecoder.decodeObject(forKey:"associationId") as? String else {fatalError()}
        
        self.init(associationId: associationId, wordPairId: wordPairId, tagId: tagId)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(wordPairId, forKey: "wordPairId")
        aCoder.encode(tagId, forKey: "tagId")
        aCoder.encode(associationId, forKey: "associationId")
        
    }
}
