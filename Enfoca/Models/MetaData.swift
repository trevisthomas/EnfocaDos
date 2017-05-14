//
//  MetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class MetaData : Hashable {
    static let formatter = Formatter()
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: MetaData, rhs: MetaData) -> Bool {
        return lhs.metaId == rhs.metaId
    }
    
    var hashValue: Int {
        return pairId.hashValue
    }
    
    
    private(set) var metaId: String
    private(set) var pairId: String
    private(set) var dateCreated: Date
    private(set) var dateUpdated: Date?
    private(set) var incorrectCount: Int
    private(set) var totalTime: Int
    private(set) var timedViewCount: Int
    
    
    
    var confidence : Int {
        return 0
    }
    
//    var difficulty : Double {
//        return 0
//    }
    
    //The precentage of times the word was guessd correctly
    var score : Double {
        return Double(timedViewCount - incorrectCount) / Double(timedViewCount)
    }
    
    var scoreAsString : String? {
        if timedViewCount > 0 {
            return String(format: "%.0f%%", arguments: [score * 100])
        } else {
            return nil
        }
        
    }
    
    var averageTime: Int {
        return totalTime / timedViewCount
    }
    
    
    init(metaId: String, pairId : String, dateCreated : Date, dateUpdated: Date?, incorrectCount: Int, totalTime: Int, timedViewCount: Int){
        self.metaId = metaId
        self.pairId = pairId
        self.dateCreated = dateCreated
        self.dateUpdated = dateUpdated
        self.incorrectCount = incorrectCount
        self.totalTime = totalTime
        self.timedViewCount = timedViewCount
    }

    
    
    public init (json: String) {
        guard let jsonData = json.data(using: .utf8) else { fatalError() }
        guard let jsonResult: NSDictionary = try! JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary else {fatalError()}
        
        guard let metaId = jsonResult["metaId"] as? String else {fatalError()}
        guard let pairId = jsonResult["pairId"] as? String else {fatalError()}
        
        guard let dateCreatedString = jsonResult["dateCreated"] as? String else {fatalError()}
        guard let dateCreated = JsonDateFormatter.instance.date(from: dateCreatedString) else {fatalError()}
        
        
        if let dateUpdatedString = jsonResult["dateUpdated"] as? String {
            guard let dateUpdated = JsonDateFormatter.instance.date(from: dateUpdatedString) else {fatalError()}
            self.dateUpdated = dateUpdated
        }
        
        guard let incorrectCount = jsonResult["incorrectCount"] as? Int else {fatalError()}
        guard let totalTime = jsonResult["totalTime"] as? Int else {fatalError()}
        guard let timedViewCount = jsonResult["timedViewCount"] as? Int else {fatalError()}
        
        self.metaId = metaId
        self.pairId = pairId
        self.dateCreated = dateCreated
//        self.dateUpdated = dateUpdated
        self.incorrectCount = incorrectCount
        self.totalTime = totalTime
        self.timedViewCount = timedViewCount
    }
    
    public func toJson() -> String {
        var representation = [String: AnyObject]()
        
        representation["metaId"] = metaId as AnyObject?
        representation["pairId"] = pairId as AnyObject?
        representation["incorrectCount"] = incorrectCount as AnyObject?
        representation["totalTime"] = totalTime as AnyObject?
        representation["timedViewCount"] = timedViewCount as AnyObject?
        
        let dateCreatedString = JsonDateFormatter.instance.string(from: dateCreated)
        representation["dateCreated"] = dateCreatedString as AnyObject?
        
        if let updated = dateUpdated {
            let dateUpdatedString = JsonDateFormatter.instance.string(from: updated)
            representation["dateUpdated"] = dateUpdatedString as AnyObject?
        }
        
        
        guard let data = try? JSONSerialization.data(withJSONObject: representation, options: []) else { fatalError() }
        
        guard let json = String(data: data, encoding: .utf8) else { fatalError() }
        
        return json
    }
}
