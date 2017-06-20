//
//  MatchingRoundAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


class MatchingRoundAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    //        private let duration = 4.0
    private let duration : Double = 0.8
    
    var presenting: Bool = true
    
    
    // This is used for percent driven interactive transitions, as well as for
    // container controllers that have companion animations that might need to
    // synchronize with the main animation.
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if presenting {
            present(context: transitionContext)
        } else {
            dissmiss(context: transitionContext)
        }
    }
    
    private func present(context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        guard let toViewController = context.viewController(forKey: .to) as? MatchingRoundViewController else {
            fatalError()
        }
        
        
        guard let fromViewController = context.viewController(forKey: .from) as? ChangeCardAnimatorTarget else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        toViewController.view.alpha = 0
        
        CustomAnimations.animateExpandAndPullOut(target: fromViewController.rightNavButton()!, delay: 0.0, duration: duration * 0.33)
        
        CustomAnimations.animateExpandAndPullOut(target: fromViewController.getTitleLabel()!, delay: duration * 0.17, duration: duration * 0.33)
        
        CustomAnimations.performSwitch(myDuration: duration * 0.5, cardView: fromViewController.getCardView(), containerView: containerView, toTheLeft: true, forward: true) { 
            //done
        
            CustomAnimations.animatePopIn(target: toViewController.titleLabel, delay: 0.0, duration: self.duration * 0.33)
            
            toViewController.view.alpha = 1
            let oldTopConstant = toViewController.mainTopViewConstraint.constant
            toViewController.mainTopViewConstraint.constant = containerView.frame.height
            
            toViewController.view.layoutIfNeeded()
            
            toViewController.mainTopViewConstraint.constant = oldTopConstant
            
            UIView.animate(withDuration: self.duration * 0.5, animations: {
                toViewController.view.layoutIfNeeded()
            }) { (_ : Bool) in
                
                toViewController.animateCellsIntoView()
                context.completeTransition(true)
            }
        }
        
        
    }
    
    private func dissmiss(context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        guard let toViewController = context.viewController(forKey: .to) as? ChangeCardAnimatorTarget else {
            fatalError()
        }
        
        
        guard let fromViewController = context.viewController(forKey: .from) as? MatchingRoundViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.getView())
        
        toViewController.getView().alpha = 0
        
        fromViewController.dismissCellsAnimated()
        
        let oldTopConstant = fromViewController.mainTopViewConstraint.constant
        
        fromViewController.mainTopViewConstraint.constant = oldTopConstant + containerView.frame.height
        
        CustomAnimations.animateExpandAndPullOut(target: fromViewController.titleLabel!, delay: duration * 0.17, duration: duration * 0.33)
        
        UIView.animate(withDuration: self.duration * 0.33, delay: self.duration * 0.33, animations: {
            fromViewController.view.layoutIfNeeded()
        }) { (_ : Bool) in
            toViewController.getView().alpha = 1
            
            CustomAnimations.animatePopIn(target: toViewController.getTitleLabel()!, delay: 0.0, duration: self.duration * 0.33)
            
            let origToAnchor = toViewController.getCardView().layer.anchorPoint
            let origToPosition = toViewController.getCardView().layer.position
            
            CustomAnimations.performSwitch(myDuration: self.duration * 0.3, cardView: toViewController.getCardView(), containerView: containerView, toTheLeft: false, forward: false) {
                
                toViewController.getCardView().layer.removeAllAnimations()
                toViewController.getCardView().layer.transform = CATransform3DIdentity
                toViewController.getCardView().layer.anchorPoint = origToAnchor
                toViewController.getCardView().layer.position = origToPosition
                
                context.completeTransition(true)
            }
        }
    }
}
