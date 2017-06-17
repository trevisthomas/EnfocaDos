//
//  CustomAnimations.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class CustomAnimations {
    class func animateExpandAndPullOut(target: UIView, delay: Double, duration: Double, callback: @escaping ()->()) {
        UIView.animate(withDuration: duration * 0.25, delay: delay, options: [.curveEaseInOut], animations: {
            target.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (_:Bool) in
            UIView.animate(withDuration: duration * 0.75, delay: 0.0, options: [.curveEaseOut], animations: {
                target.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                target.alpha = 0
            }, completion: { (_: Bool) in
                
                callback()
            })
        }
    }
    
    class func animatePopIn(target: UIView, delay: Double, duration: Double, callback: @escaping ()->()) {
        
        target.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        target.alpha = 0
        
        UIView.animate(withDuration: duration * 0.75, delay: delay, options: [.curveEaseInOut], animations: {
            target.alpha = 1
            target.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (_:Bool) in
            UIView.animate(withDuration: duration * 0.25, delay: 0.0, options: [.curveEaseOut], animations: {
                target.transform = .identity
            }, completion: { (_: Bool) in
                callback()
            })
        }
    }
    
    class func animateEndFlip(target: UIView, duration: Double, counterClockwise: Bool, callback: @escaping()->() = {}){
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            target.layer.transform = CATransform3DIdentity
            target.layer.removeAllAnimations()
            
            callback()
        })
        
        var rotateTransform = CATransform3DRotate(target.layer.transform , 0.0 * .pi, 0.0, 1.0, 0.0)
        
        rotateTransform.m34 = 1.0 / -1500;
        
        target.layer.transform = rotateTransform
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        
        if counterClockwise {
            rotateAnimation.fromValue = 0.5 * .pi
            rotateAnimation.toValue = 0
        } else {
            rotateAnimation.fromValue = -0.5 * .pi
            rotateAnimation.toValue = 0.0
        }
        
        //        rotateAnimation.beginTime = CACurrentMediaTime() + duration * 0.5
        rotateAnimation.fillMode = kCAFillModeBackwards
        rotateAnimation.isRemovedOnCompletion = true
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        rotateAnimation.duration =  duration
        
        target.layer.add(rotateAnimation, forKey: nil)
        
        //Scale it before you start
        target.layer.transform = CATransform3DMakeScale(1.0, 1.0, 0.8)
        
        let scaleAnimation = createScaleAnimation(delay: true, duration: duration * 0.8)
        target.layer.add(scaleAnimation, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    //This seems less useful to be public but at the moment it is used in two places.  
    // If you refactor the front half of the flip animation and bring that in here then maybe you can make this private.  
    class func createScaleAnimation(delay: Bool = false, duration: Double) -> CABasicAnimation {
        let ani = CABasicAnimation(keyPath: "transform.scale")
        
        if delay {
            ani.fromValue = 0.8
            ani.toValue = 1.0
        } else {
            ani.fromValue = 1.0
            ani.toValue = 0.8
        }
        
        ani.fillMode = kCAFillModeForwards
        ani.isRemovedOnCompletion = false
        ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        ani.duration =  duration
        return ani
    }

}
