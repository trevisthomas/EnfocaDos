//
//  HomeAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

public class HomeFromLoadingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 1.0
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toViewController = transitionContext.viewController(forKey: .to) as? ModularHomeViewController else {
            fatalError()
        }
        
        
        containerView.addSubview(toViewController.view)
        
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
        
        //Magic happens
        toViewController.view.layoutIfNeeded()
        
        toViewController.languageSelectorLeftConstraint.constant = origLanguageConstant
        toViewController.searchOrCreateLeftConstraint.constant = origSearchConstant
        toViewController.searchResultsTableViewContainerLeftConstraint.constant = origSearchTableConstant
        toViewController.quizLabelLeftConstraint.constant = origQuizLabelConstant
        toViewController.browseLabelLeftConstraint.constant = origBrowseLabelConstant
        
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            
            toViewController.view.layoutIfNeeded()
            
        }) { _ in
            transitionContext.completeTransition(true)
//            toViewController.transitionComplete()
        }
        
        UIView.animate(withDuration: duration * 0.33, delay: 0, options: [.curveEaseInOut], animations: {
            
        }) { _ in
            //Wow.  Is this the best TODO: Consider alternative
            toViewController.magifierCloseView.initialize()
        }
        
        UIView.animate(withDuration: duration * 0.33, delay: duration * 0.66, options: [.curveEaseInOut], animations: {
            toViewController.titleLabel.alpha = 1
        }) { _ in
            //nada
        }
    }
 
}

