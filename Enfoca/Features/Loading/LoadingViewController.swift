//
//  LoadingViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {
    fileprivate var progressLabels : [String: UILabel] = [:]
    @IBOutlet weak var messageStackView: UIStackView!

//    @IBOutlet weak var darkGreyBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var darkGrayHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let originalHeight = darkGrayHeightConstraint.constant
        darkGrayHeightConstraint.constant = view.frame.height
        self.view.layoutIfNeeded()
        
        //lol, i had to get off of the thread to allow the initial conditions to be applied and then start the animation.  Mainly this was so that IB could show the final state.
        invokeLater {
            self.darkGrayHeightConstraint.constant = originalHeight
            
            UIView.animate(withDuration: 0.66, delay: 0.2, options: [.curveEaseOut], animations: {
                self.view.layoutIfNeeded()
            }) { (_) in
                //Done
            }
        }
        
        initialize()
    }
    
    private func initialize(){
        let service = LocalCloudKitWebService()
        //        let service = CloudKitWebService()
        //        let service = DemoWebService()
        service.initialize(dataStore: getAppDelegate().applicationDefaults.dataStore, progressObserver: self) { (success :Bool, error : EnfocaError?) in
            
            if let error = error {
                self.presentAlert(title: "Initialization error", message: error)
            } else {
                getAppDelegate().webService = service
                self.performSegue(withIdentifier: "Home", sender: self)
            }
            
            //            //DELETE ALL
            //            Perform.deleteAllRecords(dataStore: getAppDelegate().applicationDefaults.dataStore, enfocaId: service.enfocaId, db: service.db)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

extension LoadingViewController : ProgressObserver {
    func startProgress(ofType key : String, message: String){
        print("Starting: \(key) : \(message)")
        
        DispatchQueue.main.async {
            let label = UILabel()
            
            label.text = message
            self.progressLabels[key] = label
            self.messageStackView.addArrangedSubview(label)
            self.messageStackView.translatesAutoresizingMaskIntoConstraints = false;
        }
    }
    func updateProgress(ofType key : String, message: String){
        DispatchQueue.main.async {
            guard let label = self.progressLabels[key] else { return }
            label.text = message
        }
    }
    func endProgress(ofType key : String, message: String) {
        print("Ending: \(key) : \(message)")
        DispatchQueue.main.async {
            guard let label = self.progressLabels[key] else { return }
            label.text = nil
            self.messageStackView.removeArrangedSubview(label)
            self.progressLabels[key] = nil
            
        }
    }
    
}

