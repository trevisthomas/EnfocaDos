//
//  WordPair.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class WordPair : NSObject, NSCoding {
    static let formatter = Formatter()
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: WordPair, rhs: WordPair) -> Bool {
        return lhs.pairId == rhs.pairId
    }
    
//    var hashValue: Int {
//        return pairId.hashValue
//    }
    
    private(set) var pairId: String
    private(set) var word: String
    private(set) var definition: String
    private(set) var dateCreated: Date
    private(set) var gender: Gender
    private(set) var example: String?
    private(set) var tags : [Tag] = []
    
    init (pairId: String, word: String, definition: String, dateCreated: Date = Date(), gender: Gender = .notset, tags : [Tag] = [], example: String? = nil) {
        self.pairId = pairId
        self.word = word
        self.definition = definition
        self.dateCreated = dateCreated
        self.gender = gender
        self.tags = tags
        self.example = example
    }
    
    func applyUpdate(source: WordPair) {
        self.word = source.word
        self.definition = source.definition
        self.gender = source.gender
        self.example = source.example
        //Tags?
    }
    
    func addTag(_ tag : Tag) {
        tags.append(tag)
        tags.sort { (t1:Tag, t2:Tag) -> Bool in
            return t1.name.lowercased() < t2.name.lowercased()
        }
    }
    
    func clearTags(){
        tags.removeAll()
    }
    
    func remove(tag: Tag) -> Tag? {
        guard let index = tags.index(of: tag) else {
            return nil
        }
        return tags.remove(at: index)
    }
    
    public init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        
        
        guard let pairId = jsonResult["pairId"] as? String else {fatalError()}
        guard let word = jsonResult["word"] as? String else {fatalError()}
        guard let definition = jsonResult["definition"] as? String else {fatalError()}
        
        guard let dateString = jsonResult["dateCreated"] as? String else {fatalError()}
        guard let genderString = jsonResult["gender"] as? String else { fatalError() }
        
        guard let dateCreated = JsonDateFormatter.instance.date(from: dateString) else {fatalError()}
        let gender = Gender.fromString(genderString)
        
        
        
        self.pairId = pairId
        self.word = word
        self.definition = definition
        self.dateCreated = dateCreated
        self.gender = gender
        self.example = jsonResult["example"] as? String
        
    }
    
    public func toJson() -> String {
        var representation = [String: AnyObject]()
        
        representation["pairId"] = pairId as AnyObject?
        representation["word"] = word as AnyObject?
        representation["definition"] = definition as AnyObject?
        let dateString = JsonDateFormatter.instance.string(from: dateCreated)
        representation["dateCreated"] = dateString as AnyObject?
        representation["gender"] = gender.toString() as AnyObject?
        representation["example"] = example as AnyObject?
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        guard let pairId = aDecoder.decodeObject(forKey:"pairId") as? String else {fatalError()}
        guard let word = aDecoder.decodeObject(forKey:"word") as? String else {fatalError()}
        guard let definition = aDecoder.decodeObject(forKey:"definition") as? String else {fatalError()}
        
        guard let dateString = aDecoder.decodeObject(forKey:"dateCreated") as? String else {fatalError()}
        guard let genderString = aDecoder.decodeObject(forKey:"gender") as? String else { fatalError() }
        
        guard let dateCreated = JsonDateFormatter.instance.date(from: dateString) else {fatalError()}
        let gender = Gender.fromString(genderString)
        let example = aDecoder.decodeObject(forKey:"example") as? String
        
        
        self.init(pairId: pairId, word: word, definition: definition, dateCreated: dateCreated, gender: gender, tags: [], example: example)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(pairId, forKey: "pairId")
        aCoder.encode(word, forKey: "word")
        aCoder.encode(definition, forKey: "definition")
        let dateString = JsonDateFormatter.instance.string(from: dateCreated)
        aCoder.encode(dateString, forKey: "dateCreated")
        aCoder.encode(gender.toString(), forKey: "gender")
        aCoder.encode(example, forKey: "example")
    }

}


