//
//  BrowseFromHomeAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

public class BrowseFromHomeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.7
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
    
    private func performDismiss() {
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? EnfocaDefaultAnimatorTarget else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? EnfocaHeaderViewAnimationTarget else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        let v = UIView()
        
        self.sourceCell.isHidden = true
        v.backgroundColor = fromViewController.getHeaderBackgroundView().backgroundColor
        
        v.frame.origin = fromViewController.getHeaderBackgroundView().frame.origin
        v.frame.size.height = fromViewController.getHeaderBackgroundView().frame.height
        v.frame.size.width = containerView.frame.width
        
        containerView.addSubview(v)
        
        
        UIView.animate(withDuration: duration * 0.6, delay: 0.0, options: [.curveEaseInOut], animations: {
            v.frame = self.sourceFrame
            
            v.backgroundColor = self.sourceCell.backgroundColor
            
            toViewController.view.alpha = 1
            
        }) { (_) in
            self.sourceCell.isHidden = false
        }
        
        fromViewController.getHeaderBackgroundView().isHidden = true
        
        UIView.animate(withDuration: duration * 0.4, delay: duration * 0.6, options: [.curveEaseInOut], animations: {
            v.alpha = 0.0
        }) { (_) in
            
            v.removeFromSuperview()
            
            fromViewController.getHeaderBackgroundView().isHidden = false
            
            self.storedContext.completeTransition(true)
        }
    }
    
    private func performPresent(){
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? EnfocaHeaderViewAnimationTarget else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.getView())
        
        
        toViewController.getView().alpha = 0
        
        CustomAnimations.bounceAnimation(view: sourceCell, amount: 1.1, duration: 0.33) {
            let duration = self.duration - 0.33
            
            let v = UIView()
            
            self.sourceCell.isHidden = true
            v.backgroundColor = self.sourceCell.backgroundColor
            v.frame = self.sourceFrame
            
            containerView.addSubview(v)
            
            UIView.animate(withDuration: duration * 0.8, delay: 0.0, options: [.curveEaseInOut], animations: {
                // For some frustrating reason the toViewController doesnt seem to have been laid out.  The dimentions that i get from it's frame are what I have setup in IB, not the device that i am running on.  I caught this because i was using an iPhone 7 emu and a Plus simuator and this frame comes back as 375, not 414.  Sigh.  Lost an hour on this.
                v.frame.origin = toViewController.getHeaderBackgroundView().frame.origin
                v.frame.size.height = toViewController.getHeaderBackgroundView().frame.height
                v.frame.size.width = containerView.frame.width
                
                v.backgroundColor = toViewController.getHeaderBackgroundView().backgroundColor
                toViewController.getView().alpha = 1
                
            }) { (_) in
                toViewController.getHeaderBackgroundView().isHidden = false
            }
            
            toViewController.getHeaderBackgroundView().isHidden = true
            
            UIView.animate(withDuration: duration * 0.2, delay: duration * 0.8, options: [.curveEaseInOut], animations: {
                v.alpha = 0.0
            }) { (_) in
                
                v.removeFromSuperview()
                self.sourceCell.isHidden = false
                self.storedContext.completeTransition(true)
            }
        }
    }
}


