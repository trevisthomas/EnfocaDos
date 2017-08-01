//
//  AnimatedCircleView.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/1/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class AnimatedCircleView: UIView {
    
    
    let checkLayer : CAShapeLayer = CAShapeLayer()
    
    
    
    //    @IBInspectable var isChecked : Bool = false
    @IBInspectable var trackColor: UIColor = UIColor.gray
    @IBInspectable var highlightColor: UIColor = UIColor.orange
    @IBInspectable var thickness: CGFloat = 20.0
    private var score: Double = 0.0
    
    var duration: Double = 0.80
    
    
    override func draw(_ rect: CGRect) {
        let check = createPath(rect: bounds, value: 100.0)
        
        trackColor.setStroke()
        check.lineWidth = thickness
        check.stroke()
        
    }
    
    
    func showScore(_ score : Double, animated: Bool = false) {
        
        
        checkLayer.removeFromSuperlayer() //Ok this is weird.
        
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.backgroundColor = (backgroundColor ?? UIColor.clear).cgColor
        checkLayer.strokeColor = highlightColor.cgColor
        checkLayer.lineWidth = thickness
        checkLayer.path = createPath(rect: bounds, value: score).cgPath
        
        let strokeAnimation = CABasicAnimation(keyPath: "strokeStart")
        //        if (checked) {
        strokeAnimation.fromValue = 1.0
        strokeAnimation.toValue = 0.0
        //        } else {
        //            strokeAnimation.fromValue = 0.0
        //            strokeAnimation.toValue = 1.0
        
        //        }
        
        
        strokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        strokeAnimation.fillMode = kCAFillModeForwards
        strokeAnimation.isRemovedOnCompletion = false
        strokeAnimation.duration = animated ? duration : 0.01
        
        checkLayer.add(strokeAnimation, forKey: nil)
        
        layer.addSublayer(checkLayer)
        
//        if (animated) {
//            UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
//                self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//            }, completion: { (_ :Bool) in
//                UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
//                    self.transform = .identity
//                }, completion: { (_ :Bool) in
//                    self.setNeedsDisplay()
//                    self.layer.removeAllAnimations()
//                })
//            })
//        }
        
        setNeedsDisplay()
    }
    
    private func createPath(rect: CGRect, value: Double) -> UIBezierPath {
        
        let radius = rect.width / 2.0 - thickness
        
        let centerPoint = CGPoint(x: rect.midX, y: rect.midY)
        
        let endAngle = (.pi * 2.0) * value
        
        let path = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0 - .pi / 2, endAngle: CGFloat(endAngle) - .pi / 2, clockwise: true)
        return path.reversing()
    }
    
    
    //    private func createCheckPath(_ rect: CGRect) -> UIBezierPath{
    //        let path = UIBezierPath()
    //
    //        let inset : CGFloat = rect.width / 3
    //
    //        let inner = rect.insetBy(dx: inset, dy: inset)
    //
    //        let startPoint = CGPoint(x: 0, y: inner.height / 2.0)
    //        let midPoint = CGPoint(x: inner.width / 2.0, y: inner.height)
    //        let endPoint = CGPoint(x: inner.width + inset * 0.5, y: 0)
    //
    //        path.move(to: startPoint)
    //        path.addLine(to: midPoint)
    //        path.addLine(to: endPoint)
    //
    //        path.apply(CGAffineTransform.init(translationX: inset * 0.7, y: inset))
    //        
    //        return path.reversing()
    //    }
    
}
