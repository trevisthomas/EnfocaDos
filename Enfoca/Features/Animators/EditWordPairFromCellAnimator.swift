//
//  editWordPairFromCellAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol EditWordPairAnimatorTarget {
    var view: UIView! {get}
    
    func getVisibleCells() -> [UITableViewCell]
    func getTableView() -> UIView
    
    func getRightNavView() -> UIView?
    func getTitleView() -> UIView
    func getHeaderHeightConstraint() -> NSLayoutConstraint
    func additionalComponentsToHide() -> [UIView] //Just return an empty list if you dont have any
}

protocol EditWordPairAnimatorDestination {
    var view: UIView! {get}
    
    func getRightNavView() -> UIView?
    func getTitleView() -> UIView
    func getHeaderHeightConstraint() -> NSLayoutConstraint

}

class EditWordPairFromCellAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 1.2
    private weak var storedContext: UIViewControllerContextTransitioning!
    var presenting: Bool = true
    
    
    var sourceCell: UITableViewCell!
    
    var originalViewFrames : [UIView: CGRect] = [:]
    
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
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? EditWordPairAnimatorDestination else {
            fatalError()
        }
        
        
//        //NOTE: Eventually from can be other places. Hm
        guard let fromViewController = storedContext.viewController(forKey: .from) as? EditWordPairAnimatorTarget else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        
        let cells = fromViewController.getVisibleCells()
        
        animateCells(away: true, visibleCells: cells, duration: duration * 0.85, screenHeight: containerView.frame.height)

        CustomAnimations.bounceAnimation(view: sourceCell, amount: 1.05, duration: 0.33)
        
        let oldTableViewBackgroundColor = fromViewController.getTableView().backgroundColor
        
//        UIView.animate(withDuration: duration * 0.1, delay: duration * 0.2, options: [], animations: {
//            fromViewController.getTableView().backgroundColor = UIColor.clear
//        }) { (_:Bool) in
//            //
//            
//        }
        
        //Header
        if let rightNavView = fromViewController.getRightNavView() {
            CustomAnimations.animateExpandAndPullOut(target: rightNavView, delay: 0.1, duration: duration * 0.6)
        }
        
        CustomAnimations.animateExpandAndPullOut(target: fromViewController.getTitleView(), delay: 0.0, duration: duration * 0.2) {
            for v in fromViewController.additionalComponentsToHide() {
                 CustomAnimations.animateExpandAndPullOut(target: v, delay: 0.0, duration: self.duration * 0.6)
            }
        }
        
        let originalFromHeaderHeight = fromViewController.getHeaderHeightConstraint().constant
        
        
        //Nudging this by 0.5 was a hack to get the animation to not fail when the header isnt moving
        fromViewController.getHeaderHeightConstraint().constant = toViewController.getHeaderHeightConstraint().constant + 0.5
        
        
        
        //Second verse
        UIView.animate(withDuration: duration * 0.15, delay: duration * 0.85, options: [.curveEaseIn], animations: {
//            toViewController.view.alpha = 1
            fromViewController.view.layoutIfNeeded()
            
        }) { (_: Bool) in
            //
            toViewController.view.alpha = 1
            
            //Reset everything!
            fromViewController.getTableView().backgroundColor = oldTableViewBackgroundColor
            
            fromViewController.getRightNavView()?.alpha = 1
            fromViewController.getTitleView().alpha = 1
            
            fromViewController.getHeaderHeightConstraint().constant = originalFromHeaderHeight
            
            for v in fromViewController.additionalComponentsToHide() {
                v.alpha = 1
            }
            
            for (v, f) in self.originalViewFrames {
                v.frame = f
            }
            
            self.storedContext.completeTransition(true)
        }
        
    }
    
    private func animateCells(away:Bool, visibleCells: [UITableViewCell], duration: Double, screenHeight: CGFloat){
        let delayPerCell = (duration * 0.5) / Double(visibleCells.count)
        
        var currentDelay = duration * 0.5
        for cell in visibleCells {
            
            let originalFrame = cell.frame
            let offScreenFrame = moveFrameSouthOfScreen(frame: cell.frame, screenHeight: screenHeight)
            
            if away {
                //do nothing
            } else {
                cell.frame = offScreenFrame
            }

            //Caching the old frame's because i cant reset them yet
            originalViewFrames[cell] = originalFrame
            
            UIView.animate(withDuration: duration * 0.5, delay: currentDelay, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                if away {
                    cell.frame = offScreenFrame
                } else {
                    cell.frame = originalFrame
                }
            }) { (_: Bool) in
                //Hm, how do i reset the frame positions?
            }
            
            currentDelay -= delayPerCell
        }
        
    }
    
    private func moveFrameSouthOfScreen(frame: CGRect, screenHeight: CGFloat) -> CGRect {
        return CGRect(x: frame.origin.x, y: frame.origin.y  + screenHeight, width: frame.width, height: frame.height)
    }
    
    private func performDismiss() {
        let containerView = storedContext.containerView
        
        
        if let toViewController = storedContext.viewController(forKey: .to) as? BrowseViewController {
            
            containerView.addSubview(toViewController.view)
            
            
            toViewController.view.alpha = 0
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
                toViewController.view.alpha = 1
            }) { (_: Bool) in
                //
                self.storedContext.completeTransition(true)
            }
        } else if let toViewController = storedContext.viewController(forKey: .to) as? HomeViewController {
            containerView.addSubview(toViewController.view)
            
            
            toViewController.view.alpha = 0
            
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseIn], animations: {
                toViewController.view.alpha = 1
            }) { (_: Bool) in
                //
                self.storedContext.completeTransition(true)
            }
        } else {
            fatalError()
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
