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
    
    fileprivate var controller: HomeController!
    
    @IBOutlet weak var quizByTagContainerView: UIView!
    @IBOutlet weak var browseByTagContainerView: UIView!
    
    fileprivate var browseByTagViewController: TagSelectionViewController!
    fileprivate var quizByTagViewControler: TagSelectionViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        initializeSubViews()
        
        controller = HomeController(delegate: self)
        getAppDelegate().activeController = controller
        
        
    }
    
    private func initializeLookAndFeel(){
        let font = Style.segmentedControlFont()
        languageSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
    }
    
    private func initializeSubViews() {
        browseByTagViewController = createTagSelectionViewController(inContainerView: browseByTagContainerView)
        
        quizByTagViewControler = createTagSelectionViewController(inContainerView: quizByTagContainerView)
    }
}

extension HomeViewController: HomeControllerDelegate{
    func onTagsLoaded(tags: [Tag]) {
        
        browseByTagViewController.initialize(tags: tags, browseDelegate: self)
        quizByTagViewControler.initialize(tags: tags, quizDelegate: self)
    }
    
    func onError(title: String, message: EnfocaError) {
        self.presentAlert(title: title, message: message)
    }
}

extension HomeViewController: BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag tag: Tag) {
        print("Browse words tagged: \(tag.name)")
    }
}

extension HomeViewController: QuizTagSelectionDelegate {
    func quizWordsWithTag(forTag tag: Tag) {
        print("Quiz words tagged: \(tag.name)")
    }
}


