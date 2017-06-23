//
//  EnfocaDefaultAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/23/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EnfocaDefaultAnimatorTarget {
    var view: UIView! {get}
    
    func getRightNavView() -> UIView?
    func getTitleView() -> UIView
    func getHeaderHeightConstraint() -> NSLayoutConstraint
    func additionalComponentsToHide() -> [UIView] //Just return an empty list if you dont have any
    func getBodyContentView() -> UIView
}

class EnfocaDefaultAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.70
    private weak var storedContext: UIViewControllerContextTransitioning!
    var presenting: Bool = true
    
    
    var sourceCell: UITableViewCell!
    
    var originalViewFrames : [UIView: CGRect] = [:]
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.storedContext = transitionContext
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? EnfocaDefaultAnimatorTarget else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? EnfocaDefaultAnimatorTarget else {
            fatalError()
        }
        
        let containerView = transitionContext.containerView
        
        containerView.addSubview(toViewController.view)
        toViewController.view.alpha = 0
        
        performPresent(to: toViewController, from: fromViewController, containerView: containerView)
        
//        if(presenting) {
//            performPresent(to: toViewController, from: fromViewController, containerView: containerView)
//        } else {
//            performDismiss(to: toViewController, from: fromViewController, containerView: containerView)
//        }
    }
    
    
    func performPresent(to: EnfocaDefaultAnimatorTarget, from: EnfocaDefaultAnimatorTarget, containerView: UIView) {
        to.view.alpha = 0.0
        
        let originalBodyFrame = from.getBodyContentView().frame
        
        animateOut(view: from, duration: duration * 0.5, contanerHeight: containerView.frame.height) { 
            
            to.view.alpha = 1
            
            to.getRightNavView()?.alpha = 0
            to.getTitleView().alpha = 0
            for v in to.additionalComponentsToHide() {
                v.alpha = 0.0
            }
            
            //
            from.getRightNavView()?.alpha = 1
            from.getTitleView().alpha = 1
            for v in from.additionalComponentsToHide() {
                v.alpha = 1
            }
            
            from.getBodyContentView().frame = originalBodyFrame
            
            
            self.animateIn(view: to, duration: self.duration * 0.5, contanerHeight: containerView.frame.height, callback: {
                
                
                self.storedContext.completeTransition(true)
            })
        }
        
    }
    
    private func animateOut(view: EnfocaDefaultAnimatorTarget, duration: Double, contanerHeight: CGFloat, callback: @escaping()->()) {
        if let rightNavView = view.getRightNavView() {
            CustomAnimations.animateExpandAndPullOut(target: rightNavView, delay: duration * 0.2, duration: duration * 0.3)
        }
        
        CustomAnimations.animateExpandAndPullOut(target: view.getTitleView(), delay: duration * 0.1, duration: duration * 0.3) {
            for v in view.additionalComponentsToHide() {
                CustomAnimations.animateExpandAndPullOut(target: v, delay: 0.0, duration: self.duration * 0.3)
            }
        }
        
        
        let originalFrame = view.getBodyContentView().frame
        
        UIView.animate(withDuration: duration * 0.8, delay: duration * 0.2, options: [.curveEaseIn], animations: {
            let newFrame = CGRect(x: originalFrame.minX, y: originalFrame.minY + contanerHeight, width: originalFrame.width, height: originalFrame.height)
            view.getBodyContentView().frame = newFrame
        }) { (_: Bool) in
            callback()
        }
    }
    
    private func animateIn(view: EnfocaDefaultAnimatorTarget, duration: Double, contanerHeight: CGFloat, callback: @escaping()->()) {
        if let rightNavView = view.getRightNavView() {
            CustomAnimations.animatePopIn(target: rightNavView, delay: duration * 0.2, duration: duration * 0.3)
        }
        
        CustomAnimations.animatePopIn(target: view.getTitleView(), delay: duration * 0.1, duration: duration * 0.3) {
            for v in view.additionalComponentsToHide() {
                CustomAnimations.animatePopIn(target: v, delay: 0.0, duration: self.duration * 0.3)
            }
        }
        
        let originalFrame = view.getBodyContentView().frame
        
        let newFrame = CGRect(x: originalFrame.minX, y: originalFrame.minY + contanerHeight, width: originalFrame.width, height: originalFrame.height)

        view.getBodyContentView().frame = newFrame
        
        UIView.animate(withDuration: duration * 0.8, delay: duration * 0.2, options: [.curveEaseIn], animations: {
            view.getBodyContentView().frame = originalFrame
        }) { (_: Bool) in
            callback()
        }
    }
    
    func performDismiss(to: EnfocaDefaultAnimatorTarget, from: EnfocaDefaultAnimatorTarget, containerView: UIView) {
        
        to.view.alpha = 0.5
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
            to.view.alpha = 1
        }) { (_: Bool) in
            //
            self.storedContext.completeTransition(true)
        }

    }
}
