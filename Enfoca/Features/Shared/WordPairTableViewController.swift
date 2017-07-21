//
//  WordPairTableViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/20/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol WordPairTableDelegate {
    func dismissKeyboard()
    func onWordPairSelected(wordPair: WordPair, atRect: CGRect, cell: UITableViewCell)
    func onCreate(atRect: CGRect, cell: UITableViewCell)
}

class WordPairTableViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var summaryLabel: UILabel!
    @IBInspectable var refreshTextColor: UIColor = UIColor.cyan
    
    fileprivate var delegate: WordPairTableDelegate!
    fileprivate var wordPairs: [WordPair] = []
    fileprivate var order: WordPairOrder!
    fileprivate var createText: String = ""
    
    fileprivate var isSortedByScore: Bool = false
    
    enum SimplifedSortMode {
        case term
        case definition
        case score
    }
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 96 //Doesn't matter
        
        tableView.separatorColor = UIColor.clear
        
        tableView.refreshControl = refreshControl
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshDataToNextSort(sender:)), for: .valueChanged)
        
        
    }
    
    fileprivate func performWordPairRefresh(_ wordPairs: ([WordPair])) {
        self.wordPairs = wordPairs
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
    }
    
    
    fileprivate func performSort(delayBy: Int? = nil) {
        let sortBy: SimplifedSortMode
        
        let message : String
        if isSortedByScore {
            message = "Sorting by score"
            sortBy = .score
            
        } else {
            if order == WordPairOrder.definitionAsc || order == WordPairOrder.definitionDesc {
                message = "Sorting by \(getAppDelegate().webService.getDefinitionTitle)"
                sortBy = .definition
            } else {
                message = "Sorting by \(getAppDelegate().webService.getTermTitle())"
                sortBy = .term
            }
        }
        
        let attributes = [ NSForegroundColorAttributeName : refreshTextColor ] as [String: Any]
        refreshControl.attributedTitle = NSAttributedString(string: message, attributes: attributes)
        
        if let delayBy = delayBy {
            delay(delayInSeconds: 1) {
                self.executeSortFunction(sortBy: sortBy)
            }
        } else {
            self.executeSortFunction(sortBy: sortBy)
        }
    }
    
    fileprivate func executeSortFunction(sortBy: SimplifedSortMode) {
        //perform sort
        
        switch sortBy {
        case .score:
            self.sortByScore(wordPairs: self.wordPairs, callback: { (wordPairs: [WordPair]) in
                self.performWordPairRefresh(wordPairs)
            })
        case .definition:
            self.sortByDefinition(wordPairs: self.self.wordPairs, callback: { (wordPairs: [WordPair]) in
                self.performWordPairRefresh(wordPairs)
            })
        case .term:
            self.sortByWord(wordPairs: self.wordPairs, callback: { (wordPairs: [WordPair]) in
                self.performWordPairRefresh(wordPairs)
            })
        }
    }
    
    func refreshDataToNextSort(sender: Any) {
        
        isSortedByScore = !isSortedByScore
        
        performSort(delayBy: 1)
    }
    
    
    func getVisibleCells() -> [UITableViewCell] {
        return tableView.visibleCells
    }
    
    func getTableView() -> UIView {
        return tableView
    }
    
    fileprivate func refresh() {
        performSort()
        
        tableView.reloadData()
        
        if wordPairs.count == 1 {
            summaryLabel.text = "One item loaded."
        } else if wordPairs.count > 1 {
            summaryLabel.text = "\(wordPairs.count) items loaded"
        } else {
            summaryLabel.text = "No items found."
        }
    }
    
    

}

extension WordPairTableViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate.dismissKeyboard()
    }
}

extension WordPairTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if createText.trim().isEmpty{
            return wordPairs.count
        } else {
            return wordPairs.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WordPairTableViewCell.identifier, for: indexPath) as! WordPairTableViewCell
        
        if (wordPairs.count <= indexPath.row) {
            cell.initialize(create: createText, order: order)
        } else {
            cell.initialize(wordPair: wordPairs[indexPath.row], order: order)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? WordPairTableViewCell else { fatalError() }
        
        CustomAnimations.bounceAnimation(view: cell, amount: 1.05, duration: 0.23) {
            let cellFrameInSuperView = self.tableView.convert(cell.frame, to: self.view.window)
            
            if cell.isCreateMode {
                self.delegate.onCreate(atRect: cellFrameInSuperView, cell: cell)
            } else {
                self.delegate.onWordPairSelected(wordPair: self.wordPairs[indexPath.row], atRect: cellFrameInSuperView, cell: cell)
            }
        }
    }
    
}

extension WordPairTableViewController {
    func initialize(delegate: WordPairTableDelegate, order: WordPairOrder, sortByScore: Bool = false){
        self.delegate = delegate
        self.order = order
        self.isSortedByScore = sortByScore
    }
    
    func updateWordPairs(order: WordPairOrder, wordPairs: [WordPair]) {
        self.order = order
        self.wordPairs = wordPairs
        refresh()
    }
    
    func clearWordPairs() {
        self.wordPairs = []
        refresh()
    }
    
    func scrollToWordPair(wordPair: WordPair) {
        guard let index = wordPairs.index(of: wordPair) else { return }
        let path = IndexPath(row: index, section: 0)
        tableView.selectRow(at: path, animated: true, scrollPosition: .middle)
    }
    
    func offerCreation(withText: String){
        createText = withText
        refresh()
    }
}


