//
//  TagSelectionViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/18/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol QuizTagSelectionDelegate {
    func quizWordsWithTag(forTag: Tag)
}

protocol BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag: Tag)
}

class TagSelectionViewController: UIViewController {
    fileprivate var quizDelegate: QuizTagSelectionDelegate?
    fileprivate var browseDelegate: BrowseTagSelectionDelegate?
    
    var animateCollectionViewCellCreation : Bool = true
    
    fileprivate var tags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func initialize(tags: [Tag], quizDelegate: QuizTagSelectionDelegate){
        self.quizDelegate = quizDelegate
        
        self.tags = []
        self.tags.append(contentsOf: tags)
    }
}

/*
 * The intended API
 */
extension TagSelectionViewController {
    
    func initialize(tags: [Tag], browseDelegate: BrowseTagSelectionDelegate){
        self.browseDelegate = browseDelegate
        
        self.tags = []
        self.tags.append(contentsOf: tags)
    }
    
    func reloadTags(tags: [Tag]){
        self.tags.removeAll()
        self.tags.append(contentsOf: tags)
    }
    
}

extension TagSelectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError()
        }
        
        let tag = tags[indexPath.row]
        if animateCollectionViewCellCreation {
            let origFram = cell.frame
            
            cell.frame = CGRect(x: origFram.origin.x + collectionView.frame.width, y: origFram.origin.y, width: origFram.width, height: origFram.height)
            
            cell.seed(tag: tag)
            
            UIView.animate(withDuration: 0.80, delay: 0.2 * (Double(indexPath.row)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                cell.frame = origFram
            }) { (_: Bool) in
                //
            }
        } else {
            cell.seed(tag: tag)
        }
        return cell
    }
    
}

extension TagSelectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tag = tags[indexPath.row]
        quizDelegate?.quizWordsWithTag(forTag: tag)
        browseDelegate?.browseWordsWithTag(withTag: tag)
    }
    
}
