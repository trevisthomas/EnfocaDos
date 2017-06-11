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
            performPresent()
        } else {
            performDismiss()
        }
    }

    
    private func performPresent() {
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
                self.secondHalf(toViewController: toViewController, fromViewController: fromViewController)
            })
        
        let fromRotateTransform = CATransform3DRotate(fromViewController.getBodyView().layer.transform, 0.0 * .pi, 0.0, 1.0, 0.0)
        
        fromViewController.getBodyView().layer.transform = fromRotateTransform
        
        
        let fromRotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        fromRotateAnimation.fromValue = 0.0
        fromRotateAnimation.toValue = -0.5 * .pi
        fromRotateAnimation.beginTime = CACurrentMediaTime()
        fromRotateAnimation.fillMode = kCAFillModeForwards
        fromRotateAnimation.isRemovedOnCompletion = false
        fromRotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        fromRotateAnimation.duration =  duration * 0.5
        
        fromViewController.getBodyView().layer.add(fromRotateAnimation, forKey: nil)
        
        CATransaction.commit()
    
    }
    
    private func secondHalf(toViewController: QuizCardAnimatorTarget, fromViewController: QuizCardAnimatorTarget){
        let containerView = storedContext.containerView
        
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            
            toViewController.getBodyView().layer.transform = CATransform3DIdentity
            toViewController.getBodyView().layer.removeAllAnimations()
            
            fromViewController.getBodyView().layer.transform = CATransform3DIdentity
            fromViewController.getBodyView().layer.removeAllAnimations()
            
            self.storedContext.completeTransition(true)
        })
        
        let rotateTransform = CATransform3DRotate(toViewController.getBodyView().layer.transform , 0.5 * .pi, 0.0, 1.0, 0.0)
        
        toViewController.getBodyView().layer.transform = rotateTransform
        
        containerView.addSubview(toViewController.getView())
        
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
        
        rotateAnimation.fromValue = 0.5 * .pi
        rotateAnimation.toValue = 0
//        rotateAnimation.beginTime = CACurrentMediaTime() + duration * 0.5
        rotateAnimation.fillMode = kCAFillModeBackwards
        rotateAnimation.isRemovedOnCompletion = true
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        rotateAnimation.duration =  duration * 0.5
        
        toViewController.getBodyView().layer.add(rotateAnimation, forKey: nil)
        
        CATransaction.commit()
        
    }
    
    
    private func performDismiss() {
        
        performPresent()
    }

}
