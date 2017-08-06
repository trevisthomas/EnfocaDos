//
//  QuizOptionsToQuizCardFrontViewAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


public class QuizOptionsToCardFrontViewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 1.0
    private weak var storedContext: UIViewControllerContextTransitioning!
    var presenting: Bool = true
    
    var sourceCell: UITableViewCell!
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.storedContext = transitionContext
        
        if(presenting) {
            performPresent()
        } else {
            fatalError()
        }
    }
    
    private func performPresent() {
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? CardFrontViewController else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? QuizOptionsViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        toViewController.view.alpha = 0
        
        let oldTopToHeaderBottomConstraint = fromViewController.topToHeaderBottomConstraint.constant
        
        let oldBodyToBottomConstraint = fromViewController.bodyToBottomConstraint.constant
        
        fromViewController.view.layoutIfNeeded()
        
        fromViewController.topToHeaderBottomConstraint.constant = oldTopToHeaderBottomConstraint + fromViewController.view.frame.height
        
        fromViewController.bodyToBottomConstraint.constant = oldBodyToBottomConstraint - fromViewController.view.frame.height
        
        let oldTitle = fromViewController.titleLabel.text
        CustomAnimations.animateExpandAndPullOut(target: fromViewController.titleLabel, delay: 0, duration: duration * 0.35, callback: {

            fromViewController.titleLabel.text = toViewController.titleLabel.text
            CustomAnimations.animatePopIn(target: fromViewController.titleLabel, delay: 0, duration: self.duration * 0.35, callback: {
                //Callback, but i cant reset the title just yet
            })
        })
        
        
        UIView.animate(withDuration: duration * 0.7, delay: 0.0, options: [.curveEaseIn], animations: {
            
            fromViewController.view.layoutIfNeeded()

        }) { (_: Bool) in
            //
            
            toViewController.view.alpha = 1
            
            CustomAnimations.animateEndFlip(target: toViewController.bodyView!, duration: self.duration * 0.3, counterClockwise: true) {
                self.storedContext.completeTransition(true)
                fromViewController.titleLabel.alpha = 1
                toViewController.view.alpha = 1
                fromViewController.titleLabel.text = oldTitle

            }
        }
    }
}


