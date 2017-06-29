//
//  Date+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

extension Date {
    var miliSeconds: Double {
        get {
            let seconds = timeIntervalSince1970
            return seconds * 1000;
        }
    }
}
