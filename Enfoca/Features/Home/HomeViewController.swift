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
    
    @IBOutlet weak var searchOrCreateTextField: UITextField!
    fileprivate var controller: HomeController!
    
    @IBOutlet weak var quizByTagContainerView: UIView!
    @IBOutlet weak var browseByTagContainerView: UIView!
    
    fileprivate var browseByTagViewController: TagSelectionViewController!
    fileprivate var quizByTagViewControler: TagSelectionViewController!
    
    @IBOutlet weak var hightConstraintOnGray: NSLayoutConstraint!
    var originalHeightConstraintOnGray: CGFloat!
    var expandedHeightConstraintOnGray: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        initializeSubViews()
        
        controller = HomeController(delegate: self)
        getAppDelegate().activeController = controller
        
        
    }
    
    private func initializeLookAndFeel(){
        originalHeightConstraintOnGray = hightConstraintOnGray.constant
        expandedHeightConstraintOnGray = view.frame.height + originalHeightConstraintOnGray
        
        searchOrCreateTextField.addTarget(self, action: #selector(searchOrCreateTextDidChange(_:)), for: [.editingChanged])
        
        let font = Style.segmentedControlFont()
        languageSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
    }
    
    private func initializeSubViews() {
        browseByTagViewController = createTagSelectionViewController(inContainerView: browseByTagContainerView)
        
        quizByTagViewControler = createTagSelectionViewController(inContainerView: quizByTagContainerView)
    }
    
    private func isWordTableContracted() -> Bool{
        return hightConstraintOnGray.constant == originalHeightConstraintOnGray
    }
    
    private func isWordTableExpanded() -> Bool{
        return hightConstraintOnGray.constant == expandedHeightConstraintOnGray
    }
    
    private func showWordTable(){
        
        guard isWordTableContracted() else {
            print("already expanded")
            return
        }
        
        hightConstraintOnGray.constant = expandedHeightConstraintOnGray

        
        UIView.animate(withDuration: 1.2, delay: 0.2, options: [.curveEaseInOut], animations: { 
            self.view.layoutIfNeeded()
        }) { ( _ ) in
            //Nada
        }
        
    }
    
    private func hideWordTable(){
        guard isWordTableExpanded() else {
            print("already contracted")
            return
        }
        
        hightConstraintOnGray.constant = originalHeightConstraintOnGray
        
        
        UIView.animate(withDuration: 0.6, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.view.layoutIfNeeded()
        }) { ( _ ) in
            //Nada
        }

    }
    
    func searchOrCreateTextDidChange(_ textField: UITextField) {
        let text = textField.text ?? ""
        
        if text.isEmpty {
            hideWordTable()
        } else {
            showWordTable()
        }
        
        print(text)
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


