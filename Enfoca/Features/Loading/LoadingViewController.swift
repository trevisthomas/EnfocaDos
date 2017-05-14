//
//  LoadingViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

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
