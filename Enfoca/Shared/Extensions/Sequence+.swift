//
//  Sequence+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/29/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == (Tag, Bool) {
    func compare(_ rhs : [(Tag, Bool)]) -> Bool{
        let array = self as! [(Tag, Bool)]
        
        if array.count != rhs.count {
            return false
        }
        
        for i in (0..<rhs.count) {
            
            let (tag, selected) = array[i]
//            if tag.tagId == rhs[i].0.tagId && selected == rhs[i].1 {
            if tag == rhs[i].0 && selected == rhs[i].1 {
                continue
            }
            return false
        }
        return true
    }
    
    func find(tag : Tag) -> TagFilter? {
        let array = self as! [(Tag, Bool)]
        guard let index = array.index(where: {
            (t, s) in
            if tag == t {
                return true
            } else {
                return false
            }
        }) else {
            return nil
        }
        return array[index]
    }
}

extension Sequence where Iterator.Element == Tag {
    func tagsToText() -> String {
        let array = self.sorted { (t1:Tag, t2:Tag) -> Bool in
            return t1.name.lowercased() < t2.name.lowercased()
        }
        var text : String = ""
        for t in array {
            if !text.isEmpty {
                text.append(", ")
            }
            text.append(t.name)
        }
        return text
    }
}

//https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

//Hm. Wrong place right?
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}



