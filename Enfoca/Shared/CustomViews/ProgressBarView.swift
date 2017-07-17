//
//  ProgressBarView.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/17/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class ProgressBarView: UIView {
    @IBInspectable var color: UIColor = UIColor.black
    
    private var max: CGFloat = 100.0
    private var current: CGFloat = 0.0
    
    func initialize(max: Int) {
        self.max = CGFloat(max)
    }
    
    func updateProgress(current: Int) {
        self.current = CGFloat(current)
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        let percentage =  current / max
        
        let xPositon = rect.width * percentage
        
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        path.addLine(to: CGPoint(x: xPositon, y: 0))
        path.addLine(to: CGPoint(x: xPositon, y: rect.maxY))
        path.addLine(to: CGPoint(x: 0, y: rect.maxY))
        path.close()
        
        color.setFill()
        path.fill()
    }
    
}
