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
    fileprivate var delegate: LanguageSelectionViewControllerDelegate!
    
    //http://www.ibabbleon.com/iOS-Language-Codes-ISO-639.html
    
    fileprivate let languages = [
        Language("English", "en"),
        Language("French", "fr"),
        Language("Spanish", "es"),
        Language("Chinese (Simplified)", "zh-Hans"),
        Language("Chinese (Traditional)", "zh-Hant")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func initialize(delegate: LanguageSelectionViewControllerDelegate){
        self.delegate = delegate
    }

}

extension LanguageSelectionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) { 
            self.delegate.languageSelected(language: self.languages[indexPath.row])
        }
    }
}

extension LanguageSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return languages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LanguageTableViewCell.identifier, for: indexPath) as! LanguageTableViewCell
        
        cell.initialize(language: languages[indexPath.row])
        
        return cell
    }
}
