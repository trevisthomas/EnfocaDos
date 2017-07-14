//
//  ColoredAngledEdgeView.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class ColoredAngledEdgeView: UIView {

    @IBInspectable var color: UIColor? = UIColor.green {
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        if let color = color {
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.close()
            
            
            color.setFill()
            
            path.fill()
        }
    }

}
