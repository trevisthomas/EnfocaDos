//
//  MultiLingualTextField.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class MultiLingualTextField: UITextField {
    var language: String?
    
    override var textInputMode: UITextInputMode? {
        guard let language = language else {
            return super.textInputMode
        }
        
        if language.isEmpty {
            return super.textInputMode
            
        } else {
            //Active Input Modes are the keyboards that the user has installed.
            for tim in UITextInputMode.activeInputModes {
                if tim.primaryLanguage!.contains(language) {
                    return tim
                }
            }
            return super.textInputMode
        }
    }
}
