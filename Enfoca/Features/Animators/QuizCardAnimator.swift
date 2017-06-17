//
//  QuizCardAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol QuizCardAnimatorTarget {
    func getBodyView() -> UIView
    func getView() -> UIView
}

class QuizCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
//    private let duration = 4.0
    private let duration = 0.60
    weak var storedContext: UIViewControllerContextTransitioning!
    
    var sourceFrame: CGRect!
    var sourceCell: UICollectionViewCell!
    var presenting: Bool = true
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.storedContext = transitionContext
        
        if(presenting) {
            performFlip(counterClockwise: true)
        } else {
            performFlip(counterClockwise: false)
        }

    }

    
    private func performFlip(counterClockwise: Bool) {
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? QuizCardAnimatorTarget else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? QuizCardAnimatorTarget else {
            fatalError()
        }
        
        containerView.addSubview(fromViewController.getView())
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
                containerView.addSubview(toViewController.getView())
            
                CustomAnimations.animateEndFlip(target: toViewController.getBodyView(), duration: self.duration * 0.5, counterClockwise: counterClockwise, callback: {
                    
                    fromViewController.getBodyView().layer.transform = CATransform3DIdentity
                    fromViewController.getBodyView().layer.removeAllAnimations()
                    
                    self.storedContext.completeTransition(true)
                })
            })
        
        var fromRotateTransform = CATransform3DRotate(fromViewController.getBodyView().layer.transform, 0.0 * .pi, 0.0, 1.0, 0.0)
        
        //Awesome!
        //https://stackoverflow.com/questions/347721/how-do-i-apply-a-perspective-transform-to-a-uiview
        fromRotateTransform.m34 = 1.0 / -1500;
        
        
        fromViewController.getBodyView().layer.transform = fromRotateTransform
        
        
        let fromRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        if counterClockwise {
            fromRotateAnimation.fromValue = 0.0
            fromRotateAnimation.toValue = -0.5 * .pi
        } else {
            fromRotateAnimation.fromValue = 0.0
            fromRotateAnimation.toValue = 0.5 * .pi
        }

        fromRotateAnimation.beginTime = CACurrentMediaTime()
        fromRotateAnimation.fillMode = kCAFillModeForwards
        fromRotateAnimation.isRemovedOnCompletion = false
        fromRotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        fromRotateAnimation.duration =  duration * 0.5
        
        fromViewController.getBodyView().layer.add(fromRotateAnimation, forKey: nil)
        
        
        let scaleAnimation = CustomAnimations.createScaleAnimation(duration: duration * 0.4)
        fromViewController.getBodyView().layer.add(scaleAnimation, forKey: nil)
        
        CATransaction.commit()
    
    }
    
}


