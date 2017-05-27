//
//  UIViewController+TransitionDelegate.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/16/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

//@deprecated
//extension UIViewController : UIViewControllerTransitioningDelegate {
//    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        //NOTE: Trevis, dont forget that you have to call '*.transitioningDelegate = self' in prepare for segue to wire things up. Dummy.
//        print("Presenting \(presenting.description)")
//        
//        if let _ = presented as? HomeViewController, let _ = source as? LoadingViewController {
//            
//            return HomeFromLoadingAnimator()
//        }
//        
//        if let _ = presented as? BrowseViewController, let _ = source as? HomeViewController {
//            return BrowseFromHomeAnimator()
//        }
//        
//        return nil
//    }
//    
//    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        print("Dismissing \(dismissed.description)")
//        
//        if let _ = dismissed as? BrowseViewController {
//            return BrowseFromHomeAnimator()
//        }
//        
//        return nil
//    }
//}
