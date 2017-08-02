//
//  CheckMarkView.swift
//  Enfoca
//
//  Created by Trevis Thomas on 3/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


@IBDesignable
class CheckMarkView : UIView {
    @IBInspectable var color: UIColor = UIColor.green
    @IBInspectable var checkColor: UIColor = UIColor.purple
    @IBInspectable var thickness: CGFloat = 2.0
    @IBInspectable var checkThickness: CGFloat = 4.0
    @IBInspectable var hideOutline: Bool = false
    
    
    let checkLayer : CAShapeLayer = CAShapeLayer()
    
    @IBInspectable var isChecked : Bool = false
    
    func checked(_ checked : Bool, animated: Bool = false) {
        isChecked = checked
        
        checkLayer.removeFromSuperlayer() //Ok this is weird.
        
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.backgroundColor = (backgroundColor ?? UIColor.clear).cgColor
        checkLayer.strokeColor = checkColor.cgColor
        checkLayer.lineWidth = checkThickness
        checkLayer.path = createCheckPath(bounds).cgPath
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeStart")
        if (checked) {
            strokeAnimation.fromValue = 1.0
            strokeAnimation.toValue = 0.0
        } else {
            strokeAnimation.fromValue = 0.0
            strokeAnimation.toValue = 1.0
            
        }
        
        
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        strokeAnimation.fillMode = kCAFillModeForwards
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.duration = animated ? 0.20 : 0.01
        
        checkLayer.add(strokeAnimation, forKey: nil)
        
        layer.addSublayer(checkLayer)
        
        if (animated) {
            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }, completion: { (_ :Bool) in
                UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                    self.transform = .identity
                }, completion: { (_ :Bool) in
                    self.setNeedsDisplay()
                    self.layer.removeAllAnimations()
                })
            })
        }
        
    }
    
    
    
    override func draw(_ rect: CGRect) {
        if !hideOutline {
            let path = UIBezierPath(ovalIn: rect.insetBy(dx: 5, dy: 5))
            
            path.lineWidth = thickness
            color.setStroke()
            
            path.stroke()
        }
        
        // This will draw a check all the time.  I was using it for debugging
        //        if (isChecked) {
        //            let check = createCheckPath(rect)
        //
        //            check.stroke()
        //        }
    }
    
    private func createCheckPath(_ rect: CGRect) -> UIBezierPath{
        let path = UIBezierPath()
        
        let inset : CGFloat = rect.width / 3
        
        let inner = rect.insetBy(dx: inset, dy: inset)
        
        let startPoint = CGPoint(x: 0, y: inner.height / 2.0)
        let midPoint = CGPoint(x: inner.width / 2.0, y: inner.height)
        let endPoint = CGPoint(x: inner.width + inset * 0.5, y: 0)
        
        path.move(to: startPoint)
        path.addLine(to: midPoint)
        path.addLine(to: endPoint)
        
        path.apply(CGAffineTransform.init(translationX: inset * 0.7, y: inset))
        
        return path.reversing()
    }
    
    private func calculateMid(_ p1 : CGPoint, _ p2 : CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2.0, y: (p1.y + p2.y) / 2.0)
    }
    
}
