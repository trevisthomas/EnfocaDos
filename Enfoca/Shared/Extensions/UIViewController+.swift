//
//  UIViewController+.swift
//  Enfoca
//
//  Created by Trevis Thomas on 12/27/16.
//  Copyright © 2016 Trevis Thomas. All rights reserved.
//

import UIKit

extension UIViewController{
    func presentAlert(title : String, message : String?){
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func services() -> WebService {
        return (UIApplication.shared.delegate as! AppDelegate).webService
    }
    
    func add(asChildViewController childViewController: UIViewController, toContainerView: UIView) {
        // Add Child View Controller
        self.addChildViewController(childViewController)
        
        // Add Child View as Subview
        toContainerView.addSubview(childViewController.view)
        
        // Configure Child View
        childViewController.view.frame = toContainerView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Notify Child View Controller
        childViewController.didMove(toParentViewController: self)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

//Is this the best place for these?
extension UIViewController {
    
    func createTagSelectionViewController(inContainerView: UIView) -> TagSelectionViewController {
        let storyboard = UIStoryboard(name: "TagSelection", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "TagSelectionViewController") as! TagSelectionViewController
        
        //Note, this add is a custom method
        self.add(asChildViewController: viewController, toContainerView: inContainerView)
        
        return viewController
    }
    
    func createWordPairTableViewController(inContainerView: UIView) -> WordPairTableViewController {
        
        let storyboard = UIStoryboard(name: "WordPairTableStoryboard", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "WordPairTableViewController") as! WordPairTableViewController
        
        //Note, this add is a custom method
        self.add(asChildViewController: viewController, toContainerView: inContainerView)
        
        return viewController
    }
    
}

