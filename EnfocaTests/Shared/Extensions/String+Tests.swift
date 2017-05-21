//
//  String+Tests.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import XCTest
@testable import Enfoca

class String_Tests: XCTestCase {
    func testTrim_ShouldTrim() {
        XCTAssertEqual("  zero ".trim(), "zero")
    }
}
