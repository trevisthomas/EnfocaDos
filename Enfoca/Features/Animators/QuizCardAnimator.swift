//
//  QuizCardAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol QuizCardAnimatorTarget {
    func getCardView() -> UIView
    func getView() -> UIView
    func rightNavButton() -> UIView?
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
        
        
        if !counterClockwise {
            
            if let navButton = fromViewController.rightNavButton() {
                CustomAnimations.animateExpandAndPullOut(target: navButton, delay: 0, duration: duration * 0.35, callback: {
                    
                    //Cant reset yet
                })
            }
        }
        
        
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
                containerView.addSubview(toViewController.getView())
            
                if counterClockwise {
                    if let navButton = toViewController.rightNavButton() {
                        CustomAnimations.animatePopIn(target: navButton, delay: 0.0, duration: self.duration * 0.35, callback: {
                            //Cant reset yet
                        })
                    }
                }
            
                CustomAnimations.animateEndFlip(target: toViewController.getCardView(), duration: self.duration * 0.5, counterClockwise: counterClockwise, callback: {
                    
                    fromViewController.getCardView().layer.transform = CATransform3DIdentity
                    fromViewController.getCardView().layer.removeAllAnimations()
                    
                    if let navButton = toViewController.rightNavButton() {
                        navButton.alpha = 1.0
                    }
                    if let navButton = fromViewController.rightNavButton() {
                        navButton.alpha = 1.0
                    }
                    self.storedContext.completeTransition(true)
                })
            })
        
        var fromRotateTransform = CATransform3DRotate(fromViewController.getCardView().layer.transform, 0.0 * .pi, 0.0, 1.0, 0.0)
        
        //Awesome!
        //https://stackoverflow.com/questions/347721/how-do-i-apply-a-perspective-transform-to-a-uiview
        fromRotateTransform.m34 = 1.0 / -1500;
        
        
        fromViewController.getCardView().layer.transform = fromRotateTransform
        
        
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
        
        fromViewController.getCardView().layer.add(fromRotateAnimation, forKey: nil)
        
        
        let scaleAnimation = CustomAnimations.createScaleAnimation(duration: duration * 0.4)
        fromViewController.getCardView().layer.add(scaleAnimation, forKey: nil)
        
        CATransaction.commit()
    
    }
    
}


