//
//  BrowseFromHomeAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

public class BrowseFromHomeAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 2.50
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
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? HomeViewController else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? BrowseViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        let v = UIView()
        
        self.sourceCell.isHidden = true
        v.backgroundColor = fromViewController.headerBackgroundView.backgroundColor
//        v.frame = self.sourceFrame
        
        v.frame.origin = fromViewController.headerBackgroundView.frame.origin
        v.frame.size.height = fromViewController.headerBackgroundView.frame.height
        v.frame.size.width = containerView.frame.width
        
        containerView.addSubview(v)
        
        
        UIView.animate(withDuration: 2.0, delay: 0.0, options: [.curveEaseInOut], animations: {
            v.frame = self.sourceFrame
            
            v.backgroundColor = self.sourceCell.backgroundColor
            
            toViewController.view.alpha = 1
            
        }) { (_) in
            v.removeFromSuperview()
            
            print(v.frame)
            self.sourceCell.isHidden = false
            
            self.storedContext.completeTransition(true)
        }
        
        
    }
    
    private func performPresent(){
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? BrowseViewController else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? HomeViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        let v = UIView()
        
        self.sourceCell.isHidden = true
        v.backgroundColor = self.sourceCell.backgroundColor
        v.frame = self.sourceFrame
        
        containerView.addSubview(v)
        
        print(containerView.frame)
        print(toViewController.headerBackgroundView.frame)
        print(toViewController.headerBackgroundView.frame.origin)
        print(toViewController.headerBackgroundView.convert(toViewController.headerBackgroundView.frame, to: toViewController.view))
        
        UIView.animate(withDuration: duration * 0.8, delay: 0.0, options: [.curveEaseInOut], animations: {
            v.frame.origin = toViewController.headerBackgroundView.frame.origin
            v.frame.size.height = toViewController.headerBackgroundView.frame.height
            v.frame.size.width = containerView.frame.width
            
            v.backgroundColor = toViewController.headerBackgroundView.backgroundColor
            toViewController.view.alpha = 1
            
        }) { (_) in
            
            
            print(v.frame)
            
            
//            self.storedContext.completeTransition(true)
        }
        
        
        toViewController.headerBackgroundView.alpha = 0
        
        UIView.animate(withDuration: duration * 0.2, delay: duration * 0.8, options: [.curveEaseInOut], animations: {
            toViewController.headerBackgroundView.alpha = 1
        }) { (_) in
            
            v.removeFromSuperview()
            self.sourceCell.isHidden = false
            self.storedContext.completeTransition(true)
        }
        
        
        
    }
    
}


