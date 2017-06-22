//
//  editWordPairFromCellAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/29/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class EditWordPairFromCellAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let duration = 2.7
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
        
        guard let toViewController = storedContext.viewController(forKey: .to) as? EditWordPairViewController else {
            fatalError()
        }
        
        
//        //NOTE: Eventually from can be other places. Hm
        guard let fromViewController = storedContext.viewController(forKey: .from) as? BrowseViewController else {
            fatalError()
        }
        
        containerView.addSubview(toViewController.view)
        
        
        toViewController.view.alpha = 0
        
        
        let cells = fromViewController.getVisibleCells()
        
        animateCells(away: true, visibleCells: cells, duration: duration * 0.5, screenHeight: containerView.frame.height)

        
        let oldTableViewBackgroundColor = fromViewController.getTableView().backgroundColor
        
        UIView.animate(withDuration: duration * 0.2, delay: duration * 0.2, options: [], animations: { 
            fromViewController.getTableView().backgroundColor = UIColor.clear
        }) { (_:Bool) in
            //
            
        }
        

//        
        UIView.animate(withDuration: duration * 0.5, delay: duration * 0.5, options: [.curveEaseIn], animations: {
            toViewController.view.alpha = 1
            
//            for view in views {
//                view.alpha = 0
//            }
        }) { (_: Bool) in
            //
            
            //Reset everything!
            fromViewController.getTableView().backgroundColor = oldTableViewBackgroundColor
            
            for (v, f) in self.originalViewFrames {
                v.frame = f
            }
            
            self.storedContext.completeTransition(true)
//            for view in views {
//                view.alpha = 1
//            }
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
