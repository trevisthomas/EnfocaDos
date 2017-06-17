//
//  Double+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/17/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

extension Double {
    var asPercent : String? {
        return String(format: "%.0f%%", arguments: [self * 100])
    }
}
