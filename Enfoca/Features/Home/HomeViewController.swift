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
    
    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var tableContainerView: UIView!
    
    fileprivate var browseByTagViewController: TagSelectionViewController!
    fileprivate var quizByTagViewControler: TagSelectionViewController!
    
    @IBOutlet weak var hightConstraintOnGray: NSLayoutConstraint!
    
    private var originalHeightConstraintOnGray: CGFloat!
    private var expandedHeightConstraintOnGray: CGFloat!
    
    fileprivate var wordPairs : [WordPair] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeLookAndFeel()
        
        initializeSubViews()
        
        controller = HomeController(delegate: self)
        getAppDelegate().activeController = controller
        
        
    }
    
    private func initializeLookAndFeel(){
        originalHeightConstraintOnGray = hightConstraintOnGray.constant
        expandedHeightConstraintOnGray = view.frame.height + originalHeightConstraintOnGray - tableContainerView.frame.height
        
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
            controller.search(pattern: text, order: .wordAsc)
            showWordTable()
        }
        
        
        print(text)
    }
}

extension HomeViewController: UITableViewDelegate {
    
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*
         This was just to see it working.  But in the process of putting this in place it dawned on me that this table that is a list of words should be in a seperate view controller.  The whole thing can then be reused as an embeded view controller.  It'll be much easier to work on the cells that way too considering the wacky animation that is in place now.
         */
        
//        tableView.dequeueReusableCell(withIdentifier: <#T##String#>)
        let cell = UITableViewCell()
        cell.textLabel?.text = wordPairs[indexPath.row].word
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wordPairs.count
    }
}


extension HomeViewController: HomeControllerDelegate{
    func onTagsLoaded(tags: [Tag]) {
        
        browseByTagViewController.initialize(tags: tags, browseDelegate: self)
        quizByTagViewControler.initialize(tags: tags, quizDelegate: self)
    }
    
    func onSearchResults(words: [WordPair]) {
        wordPairs.removeAll()
        wordPairs.append(contentsOf: words)
        searchTableView.reloadData()
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


