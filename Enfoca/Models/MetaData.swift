//
//  MetaData.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class MetaData : NSObject, NSCoding /*, Hashable*/ {
    static let formatter = Formatter()
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    
    //http://mgrebenets.github.io/swift/2015/06/21/equatable-nsobject-with-swift-2
    override func isEqual(_ object: Any?) -> Bool {
        if let rhs = object as? MetaData {
            return metaId == rhs.metaId
        }
        return false
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
        if timedViewCount == 0 {
            return 0.0
        }
        return Double(timedViewCount - incorrectCount) / Double(timedViewCount)
    }
    
    var scoreAsString : String? {
        if timedViewCount > 0 {
            return score.asPercent
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

    func updateScore(isCorrect: Bool, elapsedTime: Int) {
        if isCorrect {
            correct(elapsedTime: elapsedTime)
        } else {
            incorrect(elapsedTime: elapsedTime)
        }
    }
    
    func correct(elapsedTime: Int){
        dateUpdated = Date()
        timedViewCount += 1
        
        totalTime += elapsedTime
    }
    
    func incorrect(elapsedTime: Int){
        dateUpdated = Date()
        timedViewCount += 1
        incorrectCount += 1
        
        totalTime += elapsedTime
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
    
    required convenience init(coder aDecoder: NSCoder) {
        guard let metaId = aDecoder.decodeObject(forKey:"metaId") as? String else {fatalError()}
        guard let pairId = aDecoder.decodeObject(forKey:"pairId") as? String else {fatalError()}
        guard let dateCreated = aDecoder.decodeObject(forKey:"dateCreated") as? Date else {fatalError()}
        
        let dateUpdated = aDecoder.decodeObject(forKey:"dateUpdated") as? Date
        
        let incorrectCount = aDecoder.decodeInteger(forKey:"incorrectCount")
        let totalTime = aDecoder.decodeInteger(forKey:"totalTime")
        let timedViewCount = aDecoder.decodeInteger(forKey:"timedViewCount")
        
        self.init(metaId: metaId, pairId: pairId, dateCreated: dateCreated, dateUpdated: dateUpdated, incorrectCount: incorrectCount, totalTime: totalTime, timedViewCount: timedViewCount)
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(metaId, forKey: "metaId")
        aCoder.encode(pairId, forKey: "pairId")
        aCoder.encode(incorrectCount, forKey: "incorrectCount")
        aCoder.encode(totalTime, forKey: "totalTime")
        aCoder.encode(timedViewCount, forKey: "timedViewCount")
        aCoder.encode(dateCreated, forKey: "dateCreated")
        if let updated = dateUpdated {
            aCoder.encode(updated, forKey: "dateUpdated")
        }
        
    }
}
