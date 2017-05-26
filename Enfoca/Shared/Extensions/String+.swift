//
//  String+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
