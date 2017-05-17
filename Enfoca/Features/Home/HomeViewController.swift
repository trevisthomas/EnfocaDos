//
//  HomeViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, HomeControllerDelegate {

    @IBOutlet weak var oldTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var browseByTagCollectionView: UICollectionView!
    private var controller: HomeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        controller = HomeController(delegate: self)
        controller.startup()
    }
    
    private func initializeLookAndFeel(){
        let font = Style.segmentedControlFont()
        languageSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
    }
    
    func onTagsLoaded(tags: [Tag]) {
        let dataSource = self.browseByTagCollectionView.dataSource as! TagCollectionViewDataSource
        
        dataSource.updateTags(tags: tags)
        self.browseByTagCollectionView.reloadData()
    }
    
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }
}
