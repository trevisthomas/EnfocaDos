//
//  MicLevelView.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class MicLevelView: UIView {
    @IBInspectable var color: UIColor = UIColor.green

    @IBInspectable var level: CGFloat = 0.5
    
    override func draw(_ rect: CGRect) {
//        print("Mic level: \(level)")
        
        
        let radius = min(bounds.height, bounds.width) / 2.0
        let inset = radius - (radius * level)
        let path = UIBezierPath(ovalIn: bounds.insetBy(dx: inset, dy: inset))
        
        color.withAlphaComponent(level).setFill()
        
        path.fill()
    }
 
    
    //Level should be between 0 and 1
    func currentLevel(_ level: CGFloat) {
        self.level = level
        setNeedsDisplay()
        
    }
}
