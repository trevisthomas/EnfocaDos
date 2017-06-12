//
//  HomeFromQuizResultAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//


import UIKit

public class HomeFromQuizResultAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 1.0
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toViewController = transitionContext.viewController(forKey: .to) as? HomeViewController else {
            fatalError()
        }
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? QuizResultsViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        toViewController.oldTitleLabel.alpha = 0
        toViewController.titleLabel.alpha = 0
        
        
        let toViewWidth = toViewController.view.frame.width
        
        let origLanguageConstant = toViewController.languageSelectorLeftConstraint.constant
        toViewController.languageSelectorLeftConstraint.constant = toViewController.languageSelectorLeftConstraint.constant - toViewWidth
        
        let origSearchConstant = toViewController.searchOrCreateLeftConstraint.constant
        toViewController.searchOrCreateLeftConstraint.constant = origSearchConstant + toViewWidth
        let origSearchTableConstant = toViewController.searchResultsTableViewContainerLeftConstraint.constant
        toViewController.searchResultsTableViewContainerLeftConstraint.constant = origSearchTableConstant + toViewWidth
        
        let origQuizLabelConstant = toViewController.quizLabelLeftConstraint.constant
        let origBrowseLabelConstant = toViewController.browseLabelLeftConstraint.constant
        
        toViewController.quizLabelLeftConstraint.constant = origQuizLabelConstant - toViewWidth
        toViewController.browseLabelLeftConstraint.constant = origBrowseLabelConstant - toViewWidth
        
        let origHeightConstraintOnGray = toViewController.hightConstraintOnGray.constant
        
        toViewController.hightConstraintOnGray.constant = fromViewController.headerHightConstrant.constant
        
        //Magic happens
        toViewController.view.layoutIfNeeded()
        
        toViewController.hightConstraintOnGray.constant = origHeightConstraintOnGray
        
        let setupDuration = self.duration * 0.20
        
        let remainingDuration = self.duration - setupDuration
        
        UIView.animate(withDuration: setupDuration, delay: 0, options: [.curveEaseInOut], animations: {
            
            toViewController.view.layoutIfNeeded()
            
        }) { _ in
            
            toViewController.view.layoutIfNeeded()
            
            toViewController.languageSelectorLeftConstraint.constant = origLanguageConstant
            toViewController.searchOrCreateLeftConstraint.constant = origSearchConstant
            toViewController.searchResultsTableViewContainerLeftConstraint.constant = origSearchTableConstant
            toViewController.quizLabelLeftConstraint.constant = origQuizLabelConstant
            toViewController.browseLabelLeftConstraint.constant = origBrowseLabelConstant
            
            UIView.animate(withDuration: remainingDuration, delay: 0, options: [.curveEaseInOut], animations: {
                
                toViewController.view.layoutIfNeeded()
                
            }) { _ in
                transitionContext.completeTransition(true)
                toViewController.transitionComplete()
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

