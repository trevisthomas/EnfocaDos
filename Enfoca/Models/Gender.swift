//
//  Gender.swift
//  Enfoca
//
//  Created by Trevis Thomas on 1/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

enum Gender {
    case notset
    case masculine
    case feminine
    
    func toString() -> String {
        switch self {
        case .masculine:
            return "m"
        case .feminine:
            return "f"
        default:
            return "" //Hm
        }
    }
    
    static func fromString(_ string : String) -> Gender{
        switch string {
        case "m":
            return .masculine
        case "f":
            return .feminine
        default:
            return .notset
        }
    }
}
