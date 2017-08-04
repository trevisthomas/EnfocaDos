//
//  DictionaryCreationViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/26/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit



class DictionaryCreationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    
    
    var viewModel: DictionaryCreationViewModel!
    private var isBackButtonNeeded: Bool = false
    fileprivate var animator = EnfocaDefaultAnimator()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = DictionaryCreationViewModel(delegate: self)
        
        initializeLookAndFeel()
        
        refresh()
        
    }

    private func initializeLookAndFeel() {
        tableView.separatorStyle = .none
        
        backButton.isHidden = !isBackButtonNeeded
    }
    
    func initialize(isBackButtonNeeded: Bool) {
        self.isBackButtonNeeded = isBackButtonNeeded
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryEditorViewController {
            to.transitioningDelegate = self
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.initialize(dictionary: dictionary, isLanguageSelectionAvailable: false)
        } else if let to = segue.destination as? LanguageSelectionViewController {
            to.transitioningDelegate = self
            //I dont care what they choose, so i'm not passing in a delegate.
        }
    }

    @IBAction func backButtonAction(_ source: Any) {
        dismiss(animated: true) { 
            //whatever
        }
    }
    
}
extension DictionaryCreationViewController: DictionaryCreationViewModelDelegate {
    func refresh() {
        tableView.reloadData()
    }
    
    func onError(title: String, message: EnfocaError) {
        presentAlert(title: title, message: message)
    }
}

extension DictionaryCreationViewController: UITableViewDelegate {
    
}

extension DictionaryCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dictionaryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SubjectTableViewCell.identifier, for: indexPath) as? SubjectTableViewCell else { fatalError() }
        
        cell.initialize(delegate: self, title: viewModel.dictionaryList[indexPath.row])
        
        return cell
    }
}

extension DictionaryCreationViewController: SubjectTableViewCellDelegate {
    func performSelect(dictionary: UserDictionary) {
        fatalError()
    }
    func performSelect(title: String) {
        if title == viewModel.dictionaryOtherTitle {
            performSegue(withIdentifier: "CreateDictionarySegue", sender: viewModel.dictionaryOther)
        } else {
            performSegue(withIdentifier: "LanguageSelectionSegue", sender: nil)
        }
    }
}

extension DictionaryCreationViewController: EnfocaDefaultAnimatorTarget {
    func getRightNavView() -> UIView? {
        return backButton
    }
    func getTitleView() -> UIView {
        return titleLabel
    }
    
    func additionalComponentsToHide() -> [UIView] {
        return []
    }
    func getBodyContentView() -> UIView {
        return bodyView
    }
}
extension DictionaryCreationViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = true
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = false
        return animator
    }
}
