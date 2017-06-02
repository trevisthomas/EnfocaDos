//
//  editWordPairFromCellAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class EditWordPairFromCellAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 0.7
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
            performDismiss()
        }
    }

    private func performPresent() {
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? EditWordPairViewController else {
            fatalError()
        }
        
        
        //NOTE: Eventually from can be other places. Hm
        guard let fromViewController = storedContext.viewController(forKey: .from) as? BrowseViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        let views = allViewsBut(thisView: sourceCell)
        
        for view in views {
            view.alpha = 0
        }
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: { 
            toViewController.view.alpha = 1
            
//            for view in views {
//                view.alpha = 0
//            }
        }) { (_: Bool) in
            //
            self.storedContext.completeTransition(true)
        }
        
    }
    
    private func performDismiss() {
        let containerView = storedContext.containerView
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? BrowseViewController else {
            fatalError()
        }
        
        guard let fromViewController = storedContext.viewController(forKey: .from) as? EditWordPairViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
            toViewController.view.alpha = 1
        }) { (_: Bool) in
            //
            self.storedContext.completeTransition(true)
        }
    }
    
    private func allViewsBut(thisView: UIView)->[UIView] {
        let sup = thisView.superview!
        var siblings: [UIView] = []
        for subview in sup.subviews {
            if subview != thisView {
                siblings.append(subview)
            }
        }
        return siblings
    }
    
}
