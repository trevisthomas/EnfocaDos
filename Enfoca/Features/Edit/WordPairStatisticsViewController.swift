//
//  WordPairStatisticsViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class WordPairStatisticsViewController: UIViewController {
    
    @IBOutlet weak var accuracyLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var dateAddedLabel: UILabel!
    @IBOutlet weak var dateUpdatedLabel: UILabel!
    @IBOutlet weak var averageTimeLabel: UILabel!
    
    private var delegate: EditorViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 200, height: 200)
        
        refresh()
    }

    func initialize(delegate: EditorViewControllerDelegate) {
        self.delegate = delegate
    }
    
    func refresh() {
        accuracyLabel.text = delegate.score
        countLabel.text = delegate.count
        dateAddedLabel.text = delegate.dateAdded
        dateUpdatedLabel.text = delegate.dateUpdated
        averageTimeLabel.text = delegate.averageTime
    }
}
