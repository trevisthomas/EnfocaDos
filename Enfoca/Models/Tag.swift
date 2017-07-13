//
//  Tag.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/25/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

class Tag : NSObject, NSCoding /*, Equatable, Hashable*/ {
//    /// The hash value.
//    ///
//    /// Hash values are not guaranteed to be equal across different executions of
//    /// your program. Do not save hash values to use during a future execution.
//    public var hashValue: Int {
//        return tagId.hashValue
//    }
//
//    /// Returns a Boolean value indicating whether two values are equal.
//    ///
//    /// Equality is the inverse of inequality. For any values `a` and `b`,
//    /// `a == b` implies that `a != b` is `false`.
//    ///
//    /// - Parameters:
//    ///   - lhs: A value to compare.
//    ///   - rhs: Another value to compare.
//    public static func ==(lhs: Tag, rhs: Tag) -> Bool {
//        //Was this a good idea? I am relying on this implementation in the TagFilter for adding new tags.
//        //Ok, i'm trying to fix this now.
//        return lhs.tagId == rhs.tagId
////        return lhs.name == rhs.name
//    }

    private(set) var tagId : String
    private(set) var name : String
    private(set) var wordPairs : [WordPair] = []
    var count : Int {
        return wordPairs.count
    }
    
    init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
            
        guard let id = jsonResult["tagId"] as? String else {fatalError()}
        guard let name = jsonResult["name"] as? String else {fatalError()}
    
        self.tagId = id
        self.name = name
        
    }
    
    func toJson() -> String {
        var representation = [String: AnyObject]()
        representation["tagId"] = tagId as AnyObject?
        representation["name"] = name as AnyObject?
        
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
    
    init (name: String){
        self.tagId = "notset"
        self.name = name
        
    }
    
    init (tagId : String, name: String, wordPairs: [WordPair] = []){
        self.tagId = tagId
        self.name = name
        self.wordPairs = wordPairs
    }
    
    func addWordPair(_ wordPair: WordPair){
        wordPairs.append(wordPair)
    }
    
    func remove(wordPair : WordPair) -> WordPair? {
        guard let index = wordPairs.index(of: wordPair) else {
            return nil
        }
        return wordPairs.remove(at: index)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        guard let tagId = aDecoder.decodeObject(forKey:"tagId") as? String else {fatalError()}
        guard let name = aDecoder.decodeObject(forKey:"name") as? String else {fatalError()}
        guard let wordPairs = aDecoder.decodeObject(forKey:"wordPairs") as? [WordPair] else {fatalError()}
        self.init(tagId: tagId, name: name, wordPairs: wordPairs)
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(tagId, forKey: "tagId")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(wordPairs, forKey: "wordPairs")
    }
    
    func setWordPairs(wordPairs: [WordPair]){
        self.wordPairs = wordPairs
    }
}
