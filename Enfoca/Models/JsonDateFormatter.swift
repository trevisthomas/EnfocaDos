//
//  JsonDateFormatter.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

//Singleton
class JsonDateFormatter {
    
    static let instance = JsonDateFormatter()
    
    private let dateFormatter : DateFormatter
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
    public func string(from: Date) -> String{
        return dateFormatter.string(from: from)
    }
    
    public func date(from: String) -> Date? {
        return dateFormatter.date(from: from)
    }
    
}
