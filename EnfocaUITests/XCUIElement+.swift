//
//  XCUIElement+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/30/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    
    /**
     Removes any current text in the field before typing in the new value
     - Parameter text: the text to enter into the field
     */
    func clearAndEnterText(_ text: String) {
        guard let stringValue = self.value as? String else {
            XCTFail("Tried to clear and enter text into a non string value")
            return
        }
        
        self.tap()
        
        let deleteString = stringValue.characters.map { _ in XCUIKeyboardKeyDelete }.joined(separator: "")
        
        self.typeText(deleteString)
        self.typeText(text)
    }
}
