//
//  EnfocaButton.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/3/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

/*
 For some reason UIButton doesnt have a method to set the damned background color for control state.  WTF
 */
class EnfocaButton: UIButton {
    
    var isEnabledEnfoca: Bool {
        get{
            return isEnabled
        }
        set {
            isEnabled = newValue
            
            guard let _ = backgroundColorDisabled else {
                return
            }
            guard let _ = backgroundColorNormal else {
                return
            }
            
            if isEnabled {
                backgroundColor = backgroundColorNormal
            } else {
                backgroundColor = backgroundColorDisabled
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initLookAndFeel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initLookAndFeel()
    }
    
    private func initLookAndFeel(){
        layer.cornerRadius = 10
        
        backgroundColorDisabled = backgroundColor?.withAlphaComponent(0.7)
        backgroundColorNormal = backgroundColor
        
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(0.2), for: .disabled)
    }
    
    private var backgroundColorDisabled: UIColor?
    private var backgroundColorNormal: UIColor?
    
    func setBackgroundColor(_ color: UIColor?, for state: UIControlState) {
        switch state {
        case UIControlState.disabled:
            backgroundColorDisabled = color
        case UIControlState.normal:
            backgroundColorNormal = color
        default:
            abort()  //My hacked implementaiton only does the ones that i wanted.
        }
        isEnabledEnfoca = isEnabled
    }
}
