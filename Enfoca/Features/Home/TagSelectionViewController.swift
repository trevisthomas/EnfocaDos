//
//  TagSelectionViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/18/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol QuizTagSelectionDelegate {
    func quizWordsWithTag(forTag: Tag, atRect: CGRect, cell: UICollectionViewCell)
}

protocol BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag: Tag, atRect: CGRect, cell: UICollectionViewCell)
}

protocol WordTagSelectionDelegate {
    func onTagSelected(tag: Tag)
    func onTagDeselected(tag: Tag)
    func onShowTagEditor()
}

class TagSelectionViewController: UIViewController {
    
    fileprivate var quizDelegate: QuizTagSelectionDelegate?
    fileprivate var browseDelegate: BrowseTagSelectionDelegate?
    fileprivate var wordTagSelectionDelegate: WordTagSelectionDelegate?
    
    fileprivate let backgroundColor: UIColor = UIColor(hexString: "#DDDEE0")
    fileprivate let selectedBackgroundColor: UIColor = UIColor(hexString: "#A9D3AA")
    
    @IBOutlet weak var collectionView: UICollectionView!
    var animateCollectionViewCellCreation : Bool = false
    
    fileprivate let editMarkerTag = Tag(name: "...")
    
    fileprivate var tags: [Tag] = []
    fileprivate var selectedTags: [Tag] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
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
    
    func initialize(tags: [Tag], quizDelegate: QuizTagSelectionDelegate){
        self.quizDelegate = quizDelegate
        
        self.tags = []
        self.tags.append(contentsOf: tags)
    }
    
    func initialize(tags: [Tag], selectedTags: [Tag], delegate: WordTagSelectionDelegate ) {
        self.wordTagSelectionDelegate = delegate
        
        self.tags = []
        self.tags.append(editMarkerTag)
        self.tags.append(contentsOf: tags)
        
//        self.selectedTags.removeAll()
//        self.selectedTags.append(contentsOf: selectedTags)

        self.selectedTags(tags: selectedTags)
        
//        for i in 0..<tags.count {
//            let tag = tags[i]
//            
//            if (selectedTags.contains(tag)){
//                let ip = IndexPath(row: i, section: 0)
//                collectionView.selectItem(at: ip, animated: false, scrollPosition: .left)
//            }
//            
//        }
        
        collectionView.reloadData() //Woah, do i have to do this first?
        
    }
    
    func selectedTags(tags newSelectedTags: [Tag]) {
        selectedTags.removeAll()
        selectedTags.append(contentsOf: newSelectedTags)
        
        for i in 0..<tags.count {
            let tag = tags[i]
            
            if (selectedTags.contains(tag)){
                let ip = IndexPath(row: i, section: 0)
                collectionView.selectItem(at: ip, animated: false, scrollPosition: .left)
            }
            
        }
        
        //Resetting the position so that the act of setting the selcted list doesnt move the damned thing.
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
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
        
        cell.seed(tag: tag)
        
        if (selectedTags.contains(tag)){
            cell.isSelected = true
        }
        
        setCellColorIfNeeded(cell)
        
        if animateCollectionViewCellCreation {
            let origFram = cell.frame
            
            cell.frame = CGRect(x: origFram.origin.x + collectionView.frame.width, y: origFram.origin.y, width: origFram.width, height: origFram.height)
            
            UIView.animate(withDuration: 0.80, delay: 0.2 * (Double(indexPath.row)), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                cell.frame = origFram
            }) { (_: Bool) in
                //
            }
        }
        
        return cell
    }
    
    private func isSelected(indexPath: IndexPath)->Bool {
        let tag = tags[indexPath.row]
        return selectedTags.contains(tag)
    }
}

extension TagSelectionViewController : UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let tag = tags[indexPath.row]
        let cell = collectionView.cellForItem(at: indexPath)!
        
        if(tag == editMarkerTag){
            guard let wordTagSelectionDelegate = wordTagSelectionDelegate else { abort() }
            wordTagSelectionDelegate.onShowTagEditor()
//            cell.isSelected = false
            collectionView.deselectItem(at: indexPath, animated: false)
            return
        }
        
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellRect = attributes!.frame
        let cellFrameInSuperView = collectionView.convert(cellRect, to: view.window)
        
        
        setCellColorIfNeeded(cell)
        
        quizDelegate?.quizWordsWithTag(forTag: tag, atRect: cellFrameInSuperView, cell: cell)
        browseDelegate?.browseWordsWithTag(withTag: tag, atRect: cellFrameInSuperView, cell: cell)
        
        wordTagSelectionDelegate?.onTagSelected(tag: tag)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        //If we're not driving a wordTagSelectionDelegate then deselect has no meaning
        guard let _ = wordTagSelectionDelegate else {
            return
        }
        
        let tag = tags[indexPath.row]
        
        let cell = collectionView.cellForItem(at: indexPath)!
        setCellColorIfNeeded(cell)
        
        wordTagSelectionDelegate?.onTagDeselected(tag: tag)
    }
    
    func setCellColorIfNeeded(_ cell: UICollectionViewCell) {
        if let _ = wordTagSelectionDelegate {
            if cell.isSelected {
                cell.backgroundColor = selectedBackgroundColor
            } else {
                cell.backgroundColor = backgroundColor
            }
        }
    }
    
}
