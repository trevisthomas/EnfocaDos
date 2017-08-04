//
//  LanguageSelectionViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/10/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


protocol LanguageSelectionViewControllerDelegate {
    func languageSelected(language: Language?)
}


class LanguageSelectionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyView: UIView!
    
    fileprivate let animator = EnfocaDefaultAnimator()
    
    fileprivate var delegate: LanguageSelectionViewControllerDelegate!
    
    
    //http://www.ibabbleon.com/iOS-Language-Codes-ISO-639.html
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initialize(delegate: LanguageSelectionViewControllerDelegate){
        self.delegate = delegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        preferredContentSize = CGSize(width: 200, height: 200)
        
        if delegate == nil {
            backButton.isHidden = false
        } else {
            backButton.isHidden = true
        }
        
    }
    
    @IBAction func backButtonAction() {
        self.dismiss(animated: true) { 
            //Whatever
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let s = tableView.contentSize
//        
//        preferredContentSize = CGSize(width: s.width, height: s.height + headerView.frame.height)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? DictionaryEditorViewController {
            to.transitioningDelegate = self
            guard let dictionary = sender as? UserDictionary else { fatalError() }
            to.initialize(dictionary: dictionary, isLanguageSelectionAvailable: false)
        }
    }

}

extension LanguageSelectionViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = true
        return animator
        
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        animator.presenting = false
        return animator
        
    }
}

extension LanguageSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let language = Language.languages[indexPath.row]
        if delegate != nil {
            self.dismiss(animated: true) {
                self.delegate.languageSelected(language: language)
            }
        } else {
            guard let langName = language.name else { fatalError() }
            let dictionary = UserDictionary(termTitle: langName, definitionTitle: "English", subject: "\(langName) Vocabulary", language: language.code)
            performSegue(withIdentifier: "CreateDictionarySegue", sender: dictionary)
        }
    }
}

extension LanguageSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Language.languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageTableViewCell.identifier, for: indexPath) as! LanguageTableViewCell
        
        cell.initialize(language: Language.languages[indexPath.row])
        
        return cell
    }
}

extension LanguageSelectionViewController: EnfocaDefaultAnimatorTarget {
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

