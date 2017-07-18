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
    
    
    func presentAlert(title : String, message : String?, completion: @escaping ()->()){
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: completion)
    }
    
    func presentFatalAlert(title : String, message : String?){
        
        let alertController = UIAlertController(title: title, message:
            message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default,handler: { _ -> (Void) in
            abort()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentOkCancelAlert(title : String, message : String?, callback: @escaping (Bool)->()){
        let dialog = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        dialog.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            callback(true)
        }))
        
        dialog.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            callback(false)
        }))
        
        present(dialog, animated: true, completion: nil)
    }
    
    func presentActivityAlert(title: String?, message: String?) -> UIAlertController{
        
        //UIActivityViewController might be an option.
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        //create an activity indicator
        let indicator = UIActivityIndicatorView(frame: alert.view.bounds)
        indicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //add the activity indicator as a subview of the alert controller's view
        alert.view.addSubview(indicator)
        indicator.isUserInteractionEnabled = false // required otherwise if there buttons in the UIAlertController you will not be able to press them
        
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.color = UIColor.black
        indicator.startAnimating()
        
        present(alert, animated: true, completion: nil)
        
        return alert
        
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
    
    func createHomeOverlayViewController(inContainerView: UIView) -> HomeOverlayViewController {
        let storyboard = UIStoryboard(name: "Home", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "HomeOverlayViewController") as! HomeOverlayViewController
        
        //Note, this add is a custom method
        self.add(asChildViewController: viewController, toContainerView: inContainerView)
        
        return viewController
    }
    
    func createEditorViewController(inContainerView: UIView) -> EditorViewController {
        let storyboard = UIStoryboard(name: "Edit", bundle: Bundle.main)
        
        // Instantiate View Controller
        let viewController = storyboard.instantiateViewController(withIdentifier: "EditorViewController") as! EditorViewController
        
        //Note, this add is a custom method
        self.add(asChildViewController: viewController, toContainerView: inContainerView)
        
        return viewController
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
}

extension UIViewController {
    func getSubject() -> String {
        return getAppDelegate().webService.getSubject()
    }
    
    func getTermTitle() -> String {
        return getAppDelegate().webService.getTermTitle()
    }
    
    func getDefinitionTitle() -> String {
        return getAppDelegate().webService.getDefinitionTitle()
    }
}

extension UIViewController {
    func sortByWord(wordPairs: [WordPair], callback: @escaping ([WordPair])->()) {
        let sorted = wordPairs.sorted(by: { (wp1:WordPair, wp2:WordPair) -> Bool in
            return wp1.word < wp2.word
        })
        callback(sorted)
    }
    
    func sortByDefinition(wordPairs: [WordPair], callback: @escaping ([WordPair])->()) {
        let sorted = wordPairs.sorted(by: { (wp1:WordPair, wp2:WordPair) -> Bool in
            return wp1.definition < wp2.definition
        })
        callback(sorted)
    }
    
    
    func sortByScore(wordPairs: [WordPair], callback: @escaping ([WordPair])->()) {
        
        fetchMetaData(forWordPairs: wordPairs) { (metaDict: [String : MetaData?]) in
            let sorted = wordPairs.sorted(by: { (wp1:WordPair, wp2:WordPair) -> Bool in
                guard let meta1 = metaDict[wp1.pairId] as? MetaData else {
                    return false
                }
                
                guard let meta2 = metaDict[wp2.pairId] as? MetaData else {
                    return true
                }
                
                return meta1.score > meta2.score
            })
            callback(sorted)
        }
    }
    
    func fetchMetaData(forWordPairs: [WordPair], callback: @escaping ([String: MetaData?])->()) {
        var metaDataDict: [String: MetaData] = [:]
        for wordPair in forWordPairs {
            getAppDelegate().webService.fetchMetaData(forWordPair: wordPair) { (metaData: MetaData?, error) in
                metaDataDict[wordPair.pairId] = metaData
                callback(metaDataDict)
            }
        }
    }
}
