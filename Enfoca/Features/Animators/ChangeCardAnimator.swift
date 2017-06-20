//
//  ChangeCardAnimator.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/19/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol ChangeCardAnimatorTarget {
    func getCardView() -> UIView
    func getView() -> UIView
    func rightNavButton() -> UIView?
}

class ChangeCardAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
//        private let duration = 4.0
    private let duration : Double = 0.8
//    weak var storedContext: UIViewControllerContextTransitioning!
    
    var sourceFrame: CGRect!
    var sourceCell: UICollectionViewCell!
    var presenting: Bool = true
    
    
    // This is used for percent driven interactive transitions, as well as for
    // container controllers that have companion animations that might need to
    // synchronize with the main animation.
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    // This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if presenting {
//            present(context: transitionContext, toTheLeft: true)
            presentAlt(context: transitionContext)
        } else {
            fatalError() //We're like a shark.
//            dissmiss(context: transitionContext)
        }
        
    }
    
    private func presentAlt(context: UIViewControllerContextTransitioning) {
        let containerView = context.containerView
        guard let toViewController = context.viewController(forKey: .to) as? ChangeCardAnimatorTarget else {
            fatalError()
        }
        
        
        guard let fromViewController = context.viewController(forKey: .from) as? ChangeCardAnimatorTarget else {
            fatalError()
        }
        
        
        let fromCard = fromViewController.getCardView()
        
        //You have to add the view to the OS before asking about anchors and positions or the values wont work right.
        containerView.addSubview(toViewController.getView())
        toViewController.getView().alpha = 0
        
        //Backup and restore your anchor and position!
        let origFromAnchor = fromCard.layer.anchorPoint
        let origFromPosition = fromCard.layer.position
        let origToAnchor = toViewController.getCardView().layer.anchorPoint
        let origToPosition = toViewController.getCardView().layer.position
        
        
        if let navButton = fromViewController.rightNavButton() {
            CustomAnimations.animateExpandAndPullOut(target: navButton, delay: 0, duration: duration * 0.35, callback: {
                
                //Cant reset yet
            })
        }
        
        performSwitch2(myDuration: duration * 0.5, cardView: fromCard, containerView: containerView, toTheLeft: true, forward: true) {
            
            fromCard.layer.removeAllAnimations()
            
            toViewController.getView().alpha = 1
            
            let toCard = toViewController.getCardView()
            
            self.performSwitch2(myDuration: self.duration * 0.5, cardView: toCard, containerView: containerView, toTheLeft: false, forward: false, callback: {
                
                toCard.layer.removeAllAnimations()
                toCard.layer.transform = CATransform3DIdentity

                toCard.layer.anchorPoint = origToAnchor
                toCard.layer.position = origToPosition
                fromCard.layer.anchorPoint = origFromAnchor
                fromCard.layer.position = origFromPosition
                
                if let navButton = toViewController.rightNavButton() {
                    navButton.alpha = 1
                }
                
                context.completeTransition(true)
            })
        }
    }
    
    func performSwitch2(myDuration: Double, cardView: UIView, containerView: UIView, toTheLeft: Bool, forward: Bool, callback: @escaping ()->()) {
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            callback()
        })
        
        
        let moveItAnimation = CABasicAnimation(keyPath: "transform")
        
        var transform = cardView.layer.transform
        transform.m34 = 1.0 / -1500;
//        transform = CATransform3DScale(transform, 0.10, 0.10, 1.0)
        if toTheLeft{
            transform = CATransform3DRotate(transform, .pi * 0.5, 1.0, 1.0, 1.0)
        } else {
//            transform = CATransform3DRotate(transform, -.pi * 0.5, 0.0, 1.0, 0.0)
//            transform = CATransform3DRotate(transform, .pi * 0.5, 1.0, 0.0, 0.0)
            transform = CATransform3DRotate(transform, .pi * -0.5, 1.0, 1.0, 1.0)
        }
        
        if toTheLeft{
            cardView.layer.setRotationPoint(rotationPoint: CGPoint(x: -(containerView.frame.width * 4) , y: containerView.frame.height ))
        } else {
            cardView.layer.setRotationPoint(rotationPoint: CGPoint(x: containerView.frame.width * 4, y: containerView.frame.height ))
        }
        
        if forward {
            moveItAnimation.toValue = transform
        } else {
            cardView.layer.transform = transform
            moveItAnimation.toValue = CATransform3DIdentity
        }
        
        moveItAnimation.beginTime = CACurrentMediaTime()
        moveItAnimation.fillMode = kCAFillModeForwards
        moveItAnimation.isRemovedOnCompletion = false
        moveItAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        
        moveItAnimation.duration =  myDuration
        
        cardView.layer.add(moveItAnimation, forKey: nil)
        
        CATransaction.commit()
        
        
    }

}

extension CALayer {
    func setRotationPoint(rotationPoint: CGPoint) {
        
        let width = self.frame.width
        let height = self.frame.height
        let minX = self.frame.minX
        let minY = self.frame.minY
        
        let anchorPoint = CGPoint(x: (rotationPoint.x-minX)/width,
                                  y: (rotationPoint.y-minY)/height)
        
        self.anchorPoint = anchorPoint;
        self.position = rotationPoint;
        
//        print("From frame: \(self.frame)")
//        print("From anchorPoint: \(self.anchorPoint)")
//        print("From position: \(self.position)")
        
        
    }
    
    
    
}
