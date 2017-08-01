//
//  TestViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/1/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var containerView: UIView!

    var scoreViewController: ScoreViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//        scoreViewController = ScoreViewController()
        
        scoreViewController = createScoreViewController(inContainerView: containerView)
        
        scoreViewController.initialize(score: 0.25)
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
