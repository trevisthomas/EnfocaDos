//
//  MagnifierCloseView.swift
//  CheckAnimation
//
//  Created by Trevis Thomas on 5/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

@IBDesignable
class MagnifierCloseView: UIView {
    
    
    @IBInspectable var color: UIColor = UIColor.green
    @IBInspectable var bgColor: UIColor = UIColor.white
    @IBInspectable var thickness: CGFloat = 2.0
    
//    @IBInspectable var isSearchMode : Bool? = true
    var isSearchMode : Bool? = nil
    
    let magnifierHeadLayer : CAShapeLayer = CAShapeLayer()
    let handleLayer: CAShapeLayer = CAShapeLayer()
    let slashLayer: CAShapeLayer = CAShapeLayer()
    private var isInitialized: Bool?
    
    func initialize() {
        isInitialized = false
        
        self.animateInitialState()
    }
    
    
    override func draw(_ rect: CGRect) {
        color.setStroke()
        
        guard let isInitialized = isInitialized else {
            return
        }
        
        if !isInitialized {
            return
        }
        
        guard let isSearchMode = isSearchMode else {
            return
        }
        
        if (isSearchMode) {
            let magifier = magnificationCirclePath(rect)
            magifier.lineWidth = thickness
            magifier.stroke()
        } else {
            let slashOne = handlePath(rect)
            slashOne.lineWidth = thickness
            slashOne.stroke()
            
            let slashTwo = handlePath(rect, rotated: false)
            slashTwo.lineWidth = thickness
            slashTwo.stroke()
        }
    }
    
    public func toggle() {
        guard let isSearchMode = isSearchMode else {
            return
        }
        
        if(isSearchMode) {
            animateFromMagnifierToClose()
        } else {
            animateFromCloseToMagnifier()
        }
    }
    
    private func animateFromMagnifierToClose() {
        //For the animation i use two paths for the magnifyer.  One for the circle, another for the handle
        
        isSearchMode = nil //The idea is that during animation this is nil.
        layer.setNeedsDisplay() //Gives draw the opertunity to be cleared.
        
        animateTheRoundPart()
        animateTheHandle()
        animateTheOtherSlash()
        
    }
    
    private func animateFromCloseToMagnifier() {
        isSearchMode = nil //The idea is that during animation this is nil.
        layer.setNeedsDisplay() //Gives draw the opertunity to be cleared.
        
        animateTheOtherSlash(reverse: true)
        animateTheHandle(reverse: true)
        animateTheRoundPart(reverse: true)
        
        
    }
    
    
    private func animateTheRoundPart(reverse: Bool = false){
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.magnifierHeadLayer.removeFromSuperlayer()
            
            if(reverse) {
                self.handleLayer.removeAllAnimations()
                self.magnifierHeadLayer.removeAllAnimations()
                self.slashLayer.removeAllAnimations()
                self.slashLayer.removeFromSuperlayer()
                self.handleLayer.removeFromSuperlayer()
                
                self.isSearchMode = true
                self.setNeedsDisplay()
                
                self.bounceAnimation()
            }
        })
        
        magnifierHeadLayer.removeFromSuperlayer() //Ok this is weird.
        
        magnifierHeadLayer.fillColor = UIColor.clear.cgColor
        magnifierHeadLayer.backgroundColor = bgColor.cgColor
        magnifierHeadLayer.strokeColor = color.cgColor
        magnifierHeadLayer.lineWidth = thickness
        magnifierHeadLayer.path = magnifyCirclePath(bounds).cgPath
        
        let magnifierStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        if reverse {
            magnifierStrokeAnimation.fromValue = 0.0
            magnifierStrokeAnimation.toValue = 1.0
            magnifierStrokeAnimation.beginTime = CACurrentMediaTime() + 0.50
            magnifierStrokeAnimation.fillMode = kCAFillModeBackwards
            magnifierStrokeAnimation.isRemovedOnCompletion = false
            magnifierStrokeAnimation.duration =  0.40
        } else {
            magnifierStrokeAnimation.fromValue = 1.0
            magnifierStrokeAnimation.toValue = 0.0
            magnifierStrokeAnimation.fillMode = kCAFillModeForwards
            magnifierStrokeAnimation.isRemovedOnCompletion = true
            magnifierStrokeAnimation.duration =  0.50
        }
        
        
        magnifierStrokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        magnifierHeadLayer.add(magnifierStrokeAnimation, forKey: nil)
        
        layer.addSublayer(magnifierHeadLayer)
        
        CATransaction.commit()
    }
    
    private func animateTheHandle(reverse: Bool = false){
        
        CATransaction.begin()
        
        handleLayer.removeFromSuperlayer() //Maybe not needed
        handleLayer.fillColor = UIColor.clear.cgColor
        handleLayer.backgroundColor = bgColor.cgColor
        handleLayer.strokeColor = color.cgColor
        handleLayer.lineWidth = thickness
        handleLayer.path = handlePath(bounds).cgPath
        
        let handleStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        if reverse {
            handleStrokeAnimation.fromValue = 1.0
            handleStrokeAnimation.toValue = 0.33
            handleStrokeAnimation.fillMode = kCAFillModeForwards
            handleStrokeAnimation.isRemovedOnCompletion = false
        } else {
            handleStrokeAnimation.fromValue = 0.33
            handleStrokeAnimation.toValue = 1.0
            handleStrokeAnimation.beginTime = CACurrentMediaTime() + 0.50
            handleStrokeAnimation.fillMode = kCAFillModeBackwards
            handleStrokeAnimation.isRemovedOnCompletion = true
        }
        
        handleStrokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        handleStrokeAnimation.duration =  0.30
        
        handleLayer.add(handleStrokeAnimation, forKey: nil)
        
        layer.addSublayer(handleLayer)
        CATransaction.commit()
    }
    
    private func animateTheOtherSlash(reverse: Bool = false){
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            if !reverse {
                self.slashLayer.removeFromSuperlayer()
                self.handleLayer.removeFromSuperlayer()
                self.isSearchMode = false
                self.setNeedsDisplay() //Gives draw the opertunity to be cleared.
                self.bounceAnimation()
            }
        })
        
        slashLayer.fillColor = UIColor.clear.cgColor
        slashLayer.backgroundColor = bgColor.cgColor
        slashLayer.strokeColor = color.cgColor
        slashLayer.lineWidth = thickness
        
        let rotationPoint = CGPoint(x: layer.frame.width / 2.0, y: layer.frame.height / 2.0) // The point we are rotating around
        
        let width = layer.frame.width
        let height = layer.frame.height
        let minX = layer.frame.minX
        let minY = layer.frame.minY
        
        let anchorPoint = CGPoint(x: (rotationPoint.x-minX)/width,
                                  y: (rotationPoint.y-minY)/height)
        
        slashLayer.anchorPoint = anchorPoint;
        slashLayer.position = rotationPoint;
        
        let offsetFrame = CGRect(origin: rotationPoint, size: layer.frame.size)
        slashLayer.path = handlePath(offsetFrame).cgPath
        
        let slashStrokeAnimation = CABasicAnimation(keyPath: "strokeEnd")
        
        if reverse {
            slashStrokeAnimation.fromValue = 1.0
            slashStrokeAnimation.toValue = 0.33
            slashStrokeAnimation.fillMode = kCAFillModeForwards
            slashStrokeAnimation.isRemovedOnCompletion = false
        } else {
            slashStrokeAnimation.fromValue = 0.33
            slashStrokeAnimation.toValue = 1.0
            slashStrokeAnimation.beginTime = CACurrentMediaTime() + 0.50
            slashStrokeAnimation.fillMode = kCAFillModeBackwards
            slashStrokeAnimation.isRemovedOnCompletion = true
        }
        
        slashStrokeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        slashLayer.add(slashStrokeAnimation, forKey: nil)
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        
        if reverse {
            rotateAnimation.toValue = 0.0
            rotateAnimation.fromValue = .pi / 2.0
            rotateAnimation.fillMode = kCAFillModeForwards
            rotateAnimation.isRemovedOnCompletion = false
        } else {
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = .pi / 2.0
            rotateAnimation.beginTime = CACurrentMediaTime() + 0.50
            rotateAnimation.fillMode = kCAFillModeBackwards
            rotateAnimation.isRemovedOnCompletion = true
        }
        
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        rotateAnimation.duration =  0.50
        
        slashLayer.add(rotateAnimation, forKey: nil)
        
        layer.addSublayer(slashLayer)
        CATransaction.commit()
    }
    
    
    private func animateInitialState(){
        let magnifierLayer = CAShapeLayer()
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            self.isInitialized = true
            self.isSearchMode = true
            self.setNeedsDisplay()
            
            magnifierLayer.removeFromSuperlayer()
            
            self.bounceAnimation()
        })
        
        magnifierLayer.fillColor = UIColor.clear.cgColor
        magnifierLayer.backgroundColor = bgColor.cgColor
        magnifierLayer.strokeColor = color.cgColor
        magnifierLayer.lineWidth = thickness
        magnifierLayer.path = magnificationCirclePath(bounds).cgPath
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.beginTime = CACurrentMediaTime() + 0.20
        animation.fillMode = kCAFillModeBackwards
        animation.isRemovedOnCompletion = true
        
        
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        
        animation.duration =  0.70
        
        magnifierLayer.add(animation, forKey: nil)
        
        layer.addSublayer(magnifierLayer)
        
        CATransaction.commit()
    }
    
    private func magnifyCirclePath(_ rect: CGRect) -> UIBezierPath {
        let radius = rect.height * 0.15
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(7 * .pi)/4, endAngle: .pi / 4, clockwise: true)
        
        return path
    }
    
    private func handlePath(_ rect: CGRect, rotated: Bool = true) -> UIBezierPath {
        let handleRadius = rect.height * 0.33
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        let startAngle: CGFloat
        let endAngle: CGFloat
        
        if(rotated) {
            startAngle = .pi / 4
            endAngle = 5 * .pi / 4
        } else {
            startAngle = 7 * .pi / 4
            endAngle = 3 * .pi / 4
        }
        
        let bottomPoint = pointOnCircle(origin: center, radius: handleRadius, angle: startAngle)
        let topPoint = pointOnCircle(origin: center, radius: handleRadius, angle: endAngle )
        
        let path = UIBezierPath()
        
        //This transform business is for the animation for the x-slash beause i'm rotating it and animating the path
        if (rotated) {
            let transform = CGAffineTransform(translationX: -rect.origin.x, y: -rect.origin.y)
            
            path.move(to: bottomPoint.applying(transform))
            path.addLine(to: topPoint.applying(transform))
        } else {
            path.move(to: bottomPoint)
            path.addLine(to: topPoint)
        }
        
        return path
    }
    
    
    // a function to add a bit of snap. Just a quick bounce of the entire view.
    private func bounceAnimation() {
        UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn], animations: {
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { (_ :Bool) in
            UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                self.transform = .identity
            }, completion: { (_ :Bool) in })
        })
    }
    
    private func magnificationCirclePath (_ rect: CGRect) -> UIBezierPath{
        
        let radius = rect.height * 0.15
        let handleRadius = rect.height * 0.33
        
        let connectionAngle : CGFloat =  .pi / 4
        
        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        
        let handleTip = pointOnCircle(origin: center, radius: handleRadius, angle:connectionAngle )
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -(7 * .pi)/4, endAngle: connectionAngle, clockwise: true)
        
        path.addLine(to: handleTip)
        
        return path
        
    }
    
    func pointOnCircle(origin: CGPoint, radius: CGFloat, angle : CGFloat) -> CGPoint {
        let x = origin.x + radius * cos(angle)
        let y = origin.y + radius * sin(angle)
        
        return CGPoint(x: x, y: y)
    }
    
}
