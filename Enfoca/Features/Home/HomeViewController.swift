//
//  HomeViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/14/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    @IBOutlet weak var oldTitleLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var browseByTagCollectionView: UICollectionView!
    private var controller: HomeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        controller = HomeController(service: services())
        
        services().fetchUserTags { (tags: [Tag]?, error: EnfocaError?) in
            if let error = error {
                self.presentAlert(title: "Error fetching tags", message: error)
            }
            guard let tags = tags else {  fatalError() }
            
            let dataSource = self.browseByTagCollectionView.dataSource as! TagCollectionViewDataSource
            
            dataSource.updateTags(tags: tags)
            self.browseByTagCollectionView.reloadData()
        }
    }
    
    private func initializeLookAndFeel(){
        let font = Style.segmentedControlFont()
        languageSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
    }
}
