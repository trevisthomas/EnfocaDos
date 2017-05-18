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
    
    fileprivate var controller: HomeController!
    
    fileprivate var browseTagsDataSourceDelegate : TagCollectionViewDataSourceDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        controller = HomeController(delegate: self)
        getAppDelegate().activeController = controller
    }
    
    private func initializeLookAndFeel(){
        let font = Style.segmentedControlFont()
        languageSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
    }
}

extension HomeViewController: HomeControllerDelegate{
    func onTagsLoaded(tags: [Tag]) {
        browseTagsDataSourceDelegate = TagCollectionViewDataSourceDelegate(tags: tags, delegate: self)
        browseByTagCollectionView.dataSource = browseTagsDataSourceDelegate
        browseByTagCollectionView.delegate = browseTagsDataSourceDelegate
        browseByTagCollectionView.reloadData()
    }
    
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }
}

extension HomeViewController: TagCollectionDelegate {
    func tagSelected(tag: Tag) {
        print(tag.name)
    }
}
