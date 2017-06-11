//
//  QuizResultsViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/11/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class QuizResultsViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func closeButtonAction(_ sender: UIButton) {
        performSegue(withIdentifier: "HomeSegue", sender: nil)
    }

}
