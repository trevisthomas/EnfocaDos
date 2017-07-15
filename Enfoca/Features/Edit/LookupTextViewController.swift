//
//  LookupTextViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/25/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class LookupTextViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    fileprivate var urls: [String: (String)->(String)] = [:]
    fileprivate var urlKeys: [String]!
    
    private var cardSide: CardSide!
    fileprivate var arguement: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        urls["SpanichDict.com"] = { (arg: String) in
            return "http://www.spanishdict.com/translate/\(urlEncode(arg))"
        }
        urls["linguee.com"] = { (arg: String) in
            
            return "http://www.linguee.com/english-spanish/search?source=auto&query=\(urlEncode(arg))"
        }
        
        //Because dictionaries are not ordered
        urlKeys = Array(urls.keys.sorted())
        
        preferredContentSize = CGSize(width: 200, height: 200)
    }
    
    func initialize(cardSide: CardSide, arguement: String){
        self.cardSide = cardSide
        self.arguement = arguement
    }

}

extension LookupTextViewController {
    func openBrowser(address: String){
        
        guard let url = URL(string: address) else {
            self.presentAlert(title: "Browser error", message: "Unable to create url \(address)")
            return
        }
        
        let options: [String: Any] = [:]
        UIApplication.shared.open(url, options: options) { (success: Bool) in
            if !success {
                self.presentAlert(title: "Browser error", message: "Failed to launch \(url)")
            } else {
                //Dismiss?
            }
        }
        
    }
}

extension LookupTextViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected")
        
        
        guard let function = urls[urlKeys[indexPath.row]] else { fatalError("URL function not found")}
        
        openBrowser(address: function(arguement))
        
//        dismiss(animated: true) { 
//            //
//        }
    }
}

extension LookupTextViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return urlKeys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LookupTableViewCell.identifier, for: indexPath) as? LookupTableViewCell else { fatalError() }
        
        let title = urlKeys[indexPath.row]
        
        cell.linkTitleLabel.text = title
        
        return cell
    }
}
