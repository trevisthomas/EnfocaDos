//
//  HomeFromQuizResultAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//


import UIKit

protocol HomeFromQuizAnimatorTarget {
    func getHeaderHeight() -> CGFloat
}

public class HomeFromQuizResultAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 1.0
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toViewController = transitionContext.viewController(forKey: .to) as? ModularHomeViewController else {
            fatalError()
        }
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? HomeFromQuizAnimatorTarget else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        toViewController.titleLabel.alpha = 0
        
        
        let toViewWidth = toViewController.view.frame.width
        
        let origLanguageConstant = toViewController.segmentedControlLeftConstraint.constant
        toViewController.segmentedControlLeftConstraint.constant = toViewController.segmentedControlLeftConstraint.constant - toViewWidth
        
        let origSearchConstant = toViewController.searchOrCreateLeftConstraint.constant
        toViewController.searchOrCreateLeftConstraint.constant = origSearchConstant + toViewWidth
        let origSearchTableConstant = toViewController.searchResultsTableViewContainerLeftConstraint.constant
        toViewController.searchResultsTableViewContainerLeftConstraint.constant = origSearchTableConstant + toViewWidth
        
        
        let origHeightConstraintOnGray = toViewController.headerHeightConstraint.constant
        
        toViewController.headerHeightConstraint.constant = fromViewController.getHeaderHeight()
        
        //Magic happens
        toViewController.view.layoutIfNeeded()
        
        toViewController.headerHeightConstraint.constant = origHeightConstraintOnGray
        
        let setupDuration = self.duration * 0.20
        
        let remainingDuration = self.duration - setupDuration
        
        UIView.animate(withDuration: setupDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            toViewController.view.layoutIfNeeded()
            
        }) { _ in
            
            toViewController.view.layoutIfNeeded()
            
            toViewController.segmentedControlLeftConstraint.constant = origLanguageConstant
            toViewController.searchOrCreateLeftConstraint.constant = origSearchConstant
            toViewController.searchResultsTableViewContainerLeftConstraint.constant = origSearchTableConstant
//            toViewController.quizLabelLeftConstraint.constant = origQuizLabelConstant
//            toViewController.browseLabelLeftConstraint.constant = origBrowseLabelConstant
//            
            UIView.animate(withDuration: remainingDuration, delay: 0, options: [.curveEaseInOut], animations: {
                
                toViewController.view.layoutIfNeeded()
                
            }) { _ in
                transitionContext.completeTransition(true)
//                toViewController.transitionComplete()
            }
            
            UIView.animate(withDuration: remainingDuration * 0.33 , delay: 0, options: [.curveEaseInOut], animations: {
                //            toViewController.oldTitleLabel.alpha = 0
            }) { _ in
                //Wow.  Is this the best TODO: Consider alternative
                toViewController.magifierCloseView.initialize()
            }
            
            UIView.animate(withDuration: remainingDuration * 0.33, delay: remainingDuration * 0.66, options: [.curveEaseInOut], animations: {
                toViewController.titleLabel.alpha = 1
            }) { _ in
                //nada
            }
            
        }
        
        
        
        
        
    }
    
}

