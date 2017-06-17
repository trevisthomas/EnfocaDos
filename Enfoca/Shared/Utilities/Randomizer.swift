//
//  Randomizer.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/17/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

class Randomizer {
    class func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
}
