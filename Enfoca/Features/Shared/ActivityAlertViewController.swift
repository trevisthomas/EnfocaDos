//
//  ActivityAlertViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/21/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class ActivityAlertViewController: UIViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    
    private var message: String!
    func initialize(message: String) {
        self.message = message
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageLabel.text = message
    }
}
