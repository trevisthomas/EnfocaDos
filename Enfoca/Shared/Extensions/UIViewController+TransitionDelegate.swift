//
//  UIViewController+TransitionDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

extension UIViewController : UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("Presenting \(presenting.description)")
        
        if let _ = presented as? HomeViewController, let _ = source as? LoadingViewController {
            
            return HomeFromLoadingAnimator()
        }
        
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        print("Dismissing \(dismissed.description)")
        
        return nil
    }
}
