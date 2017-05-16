//
//  HomeAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

public class HomeFromLoadingAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 2.0
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        guard let toViewController = transitionContext.viewController(forKey: .to) as? HomeViewController else {
            fatalError()
        }
        
        guard let fromViewController = transitionContext.viewController(forKey: .from) as? LoadingViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
//        containerView.bringSubview(toFront: fromViewController.view)
        
//        toViewController.view.alpha = 0
        toViewController.oldTitleLabel.alpha = 1
        
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: {
            
//            toViewController
            
            toViewController.oldTitleLabel.alpha = 0
            
//            toViewController.view.alpha = 1
            
            //            toViewController.titleLabel.transform = .identity
            
//            toViewController.titleLabel.transform = scaleTransform
            
            //            toViewController.titleLabel.center = centerDest
            
            //            toViewController.titleLabel.frame.origin = newOrigin
            //            toViewController.titleLabel.layoutIfNeeded()
            
        }) { _ in
            transitionContext.completeTransition(true)
        }
        
    /*
        let xScale = fromViewController.titleLabel.frame.width / toViewController.titleLabel.frame.width
//        let yScale = fromViewController.titleLabel.frame.height / toViewController.titleLabel.frame.height
        
        let centerDest = toViewController.titleLabel.center
        
        toViewController.titleLabel.center = fromViewController.titleLabel.center
//
//        let scaleTransform = CGAffineTransform(scaleX: xScale, y: xScale)
//        toViewController.titleLabel.transform = scaleTransform
        
        
        let oldOrigin = fromViewController.titleLabel.frame.origin
        
        let labelScale = fromViewController.titleLabel.font.pointSize / toViewController.titleLabel.font.pointSize
        
//        let scaleTransform = toViewController.titleLabel.transform.scaledBy(x: labelScale, y: labelScale)
        
        let scaleTransform = toViewController.titleLabel.transform.scaledBy(x: 100, y: 100)
        
//        let newOrigin = toViewController.titleLabel.frame.origin
        
        toViewController.titleLabel.frame.origin = oldOrigin
        
//        toViewController.titleLabel.transform = scaleTransform
        
//        toViewController.titleLabel.setNeedsUpdateConstraints()
        
        UIView.animate(withDuration: duration, delay: 0, options: [.curveEaseInOut], animations: { 
//            toViewController.titleLabel.transform = .identity
            
            toViewController.titleLabel.transform = scaleTransform
            
//            toViewController.titleLabel.center = centerDest
            
//            toViewController.titleLabel.frame.origin = newOrigin
//            toViewController.titleLabel.layoutIfNeeded()
            
        }) { _ in
            transitionContext.completeTransition(true)
        }
 
 */
    }
 
}

