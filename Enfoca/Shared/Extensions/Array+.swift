//
//  Array+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/7/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

extension Array {
    func chunks(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}
