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
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        let s = tableView.contentSize
//        
//        preferredContentSize = CGSize(width: s.width, height: s.height + headerView.frame.height)
    }
    
    

}

extension LanguageSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) { 
            self.delegate.languageSelected(language: Language.languages[indexPath.row])
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
