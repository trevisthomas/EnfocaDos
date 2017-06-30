//
//  CustomAnimations.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class CustomAnimations {
    class func animateExpandAndPullOut(target: UIView, delay: Double, duration: Double, callback: @escaping ()->() = {}) {
        let originalTransform = target.transform
        UIView.animate(withDuration: duration * 0.25, delay: delay, options: [.curveEaseInOut], animations: {
            target.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }) { (_:Bool) in
            UIView.animate(withDuration: duration * 0.75, delay: 0.0, options: [.curveEaseOut], animations: {
                target.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                target.alpha = 0
            }, completion: { (_: Bool) in
                target.transform = originalTransform //Restoring the original transform, but it's invisible! User must restore alpha
                callback()
            })
        }
    }
    
    class func animatePopIn(target: UIView, delay: Double, duration: Double, callback: @escaping ()->() = {}) {
        
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

    
    //Warning! This animation leaves things in a nasty state.  You MUST fix your layer's anchorPoint and position after it has executed or you're going to have problems.  I only expose that nastyness to the user because if you're using this animation as a part of a larger series, you may need control of when you reset things.
    class func performSwitch(myDuration: Double, cardView: UIView, containerView: UIView, toTheLeft: Bool, forward: Bool, callback: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            callback()
        })
        
        
        let moveItAnimation = CABasicAnimation(keyPath: "transform")
        
        var transform = cardView.layer.transform
        transform.m34 = 1.0 / -1500;
        //        transform = CATransform3DScale(transform, 0.10, 0.10, 1.0)
        if toTheLeft{
            transform = CATransform3DRotate(transform, .pi * 0.5, 1.0, 1.0, 1.0)
        } else {
            //            transform = CATransform3DRotate(transform, -.pi * 0.5, 0.0, 1.0, 0.0)
            //            transform = CATransform3DRotate(transform, .pi * 0.5, 1.0, 0.0, 0.0)
            transform = CATransform3DRotate(transform, .pi * -0.5, 1.0, 1.0, 1.0)
        }
        
        if toTheLeft{
            cardView.layer.setRotationPoint(rotationPoint: CGPoint(x: -(containerView.frame.width * 4) , y: containerView.frame.height ))
        } else {
            cardView.layer.setRotationPoint(rotationPoint: CGPoint(x: containerView.frame.width * 4, y: containerView.frame.height ))
        }
        
        if forward {
            moveItAnimation.toValue = transform
        } else {
            cardView.layer.transform = transform
            moveItAnimation.toValue = CATransform3DIdentity
        }
        
        moveItAnimation.beginTime = CACurrentMediaTime()
        moveItAnimation.fillMode = kCAFillModeForwards
        moveItAnimation.isRemovedOnCompletion = false
        moveItAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        moveItAnimation.duration =  myDuration
        
        cardView.layer.add(moveItAnimation, forKey: nil)
        
        CATransaction.commit()
        
        
    }
    
    // a function to add a bit of snap. Just a quick bounce of the entire view.
    class func bounceAnimation(view: UIView, amount: CGFloat = 0.8, duration: Double = 0.43, callback: @escaping()->() = {}) {
        UIView.animate(withDuration: duration * 0.25, delay: 0.0, options: [.curveEaseIn], animations: {
            view.transform = CGAffineTransform(scaleX: amount, y: amount)
        }, completion: { (_ :Bool) in
            UIView.animate(withDuration: duration * 0.75, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.curveEaseOut], animations: {
                view.transform = .identity
            }, completion: { (_ :Bool) in
                callback()})
        })
    }
    
    class func bounceAnimation(view: UIView){
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.damping = 2.0
        pulse.fromValue = 1.25
        pulse.toValue = 1.0
        pulse.duration = pulse.settlingDuration
        view.layer.add(pulse, forKey: nil)
    }
    
    class func shakeAnimation(view: UIView) {
        
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.08
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fromValue = CGPoint(x: view.frame.midX - 10, y: view.frame.midY)
        animation.toValue = CGPoint(x: view.frame.midX + 10, y: view.frame.midY)
        view.layer.add(animation, forKey: "position")

    }

}
