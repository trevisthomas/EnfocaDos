//
//  TagSelectionViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 5/18/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit


protocol BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag: Tag, atRect: CGRect, cell: UICollectionViewCell)
    func showEditor(atRect: CGRect, cell: UICollectionViewCell)
}

class TagSelectionViewController: UIViewController {
    fileprivate var browseDelegate: BrowseTagSelectionDelegate?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBInspectable var refreshTextColor: UIColor = UIColor.gray
    
    var animateCollectionViewCellCreation : Bool = false
    fileprivate var cellCreationY: CGFloat?
    fileprivate var rowDivisor: Double = 1.0
    
    fileprivate let editMarkerTag = Tag(name: "...")
    fileprivate let refreshControl = UIRefreshControl()
    
    fileprivate var tags: [Tag] = []
    fileprivate var selectedTags: [Tag] = []
    
    fileprivate var isSortEnabled: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        
        let layout = collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: 100, height: 100)
        
        var size : CGFloat = 100.0
        let perRow: CGFloat = 3.0
        //
        
        
        
        size = (collectionView.frame.width - layout.sectionInset.left - layout.sectionInset.right - (layout.minimumInteritemSpacing * perRow)) / perRow
        
        //Clamp to 120 max.
        if size > 120 {
            size = 120
        }

        layout.itemSize = CGSize(width: size, height: size)
    }
    
    func refreshDataToNextSort(sender: Any) {
        
        let attributes = [ NSForegroundColorAttributeName : refreshTextColor ] as [String: Any]
        refreshControl.attributedTitle = NSAttributedString(string: "Sorting...", attributes: attributes)
        
        
        delay(delayInSeconds: 1.0) {
            let oldTagOrder = getAppDelegate().applicationDefaults.tagOrderOnHomeView
            
            let tagOrder: TagOrder
            if oldTagOrder == TagOrder.alphabetical {
                tagOrder = .color
            } else {
                tagOrder = .alphabetical
            }
            
            getAppDelegate().applicationDefaults.tagOrderOnHomeView = tagOrder
            
            self.sortTags(tagOrder: tagOrder)
            
            self.collectionView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    fileprivate func sortTags(tagOrder: TagOrder){
        
        var any: Tag? = nil
        var none: Tag? = nil
        if let index = tags.index(of: getAppDelegate().applicationDefaults.anyTag) {
            any = tags[index]
            tags.remove(at: index)
        }
        if let index = tags.index(of: getAppDelegate().applicationDefaults.noneTag) {
            none = tags[index]
            tags.remove(at: index)
        }
        
        
        switch tagOrder {
        case .color:
            tags.sort { (t1: Tag, t2: Tag) -> Bool in
                guard let c1 = t1.color else { return false }
                guard let c2 = t2.color else { return true }
                
                if c1 == c2 {
                    return t1.name.localizedCaseInsensitiveCompare(t2.name) == ComparisonResult.orderedAscending
                }
                return c1.localizedCaseInsensitiveCompare(c2) == ComparisonResult.orderedAscending
            }
        case .alphabetical:
            tags.sort { (t1: Tag, t2: Tag) -> Bool in
                    return t1.name.localizedCaseInsensitiveCompare(t2.name) == ComparisonResult.orderedAscending
            }
        }
        
        if let none = none {
            tags.insert(none, at: 0)
        }
        
        if let any = any {
            tags.insert(any, at: 0)
        }
    }
}

/*
 * The intended API
 */
extension TagSelectionViewController {
    
    func setScrollDirection(direction: UICollectionViewScrollDirection) {
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = direction
        }
    }
    
    func initialize(tags: [Tag], browseDelegate: BrowseTagSelectionDelegate, animated: Bool = false, isSortEnabled: Bool = true){
        self.browseDelegate = browseDelegate
        
        self.isSortEnabled = isSortEnabled
        
        // Configure Refresh Control
        if isSortEnabled {
            collectionView.refreshControl = refreshControl
            refreshControl.addTarget(self, action: #selector(refreshDataToNextSort(sender:)), for: .valueChanged)
        }
        
        if animated {
            turnOnAnimation()
        }
        
        self.tags = []
        self.tags.append(contentsOf: tags)
        self.sortTags(tagOrder: getAppDelegate().applicationDefaults.tagOrderOnHomeView)
        collectionView.reloadData()
        
        invokeLater {
            self.turnOffAnimation()
        }
        
    }
    
    func turnOnAnimation() {
        animateCollectionViewCellCreation = true
    }
    
    func turnOffAnimation(){
        animateCollectionViewCellCreation = false
    }
    
    func selectedTags(tags newSelectedTags: [Tag]) {
        selectedTags.removeAll()
        selectedTags.append(contentsOf: newSelectedTags)
        
//        collectionView.reloadData() //The only reason this is here is to clear the tag selection before reloading them below.
        
        for i in 0..<tags.count {
            let tag = tags[i]
            
            let ip = IndexPath(row: i, section: 0)
            if (selectedTags.contains(tag)){
                collectionView.selectItem(at: ip, animated: false, scrollPosition: .left)
            }
            
        }
        
        //Resetting the position so that the act of setting the selcted list doesnt move the damned thing.
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
        
        
    }
    
    func reloadTags(tags: [Tag]){
        self.tags.removeAll()
        self.tags.append(contentsOf: tags)
        
        collectionView.reloadData()
    }
    
}

extension TagSelectionViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return tags.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TagCollectionViewCell.identifier, for: indexPath) as? TagCollectionViewCell else {
            fatalError()
        }
        
        let tag: Tag
        if (indexPath.row == 0) {
            tag = editMarkerTag
        } else {
            tag = tags[indexPath.row - 1]
        }
        
        cell.seed(tag: tag)
        
        if animateCollectionViewCellCreation {
            let origFram = cell.frame
            
            if cellCreationY == nil {
                cellCreationY = cell.frame.minY
            }
            
            if cell.frame.minY > cellCreationY! {
                rowDivisor = rowDivisor + 1.0
                cellCreationY = cell.frame.minY
            }
            
            cell.frame = CGRect(x: origFram.origin.x + collectionView.frame.width, y: origFram.origin.y, width: origFram.width, height: origFram.height)
            
            UIView.animate(withDuration: 0.33, delay: 0.1 * (Double(indexPath.row) / rowDivisor), usingSpringWithDamping: 0.8, initialSpringVelocity: 0.0, options: [], animations: {
                cell.frame = origFram
            }) { (_: Bool) in
                //
            }
        }
        
        if (indexPath.row == 0) {
            cell.backgroundColor = Theme.gray
        }
        else {
//            cell.backgroundColor = Theme.green
            cell.backgroundColor = Theme.gray
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
        
        let cell = collectionView.cellForItem(at: indexPath)!
        
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellRect = attributes!.frame
        let cellFrameInSuperView = collectionView.convert(cellRect, to: view.window)
        
        if indexPath.row == 0 {
            browseDelegate?.showEditor(atRect: cellFrameInSuperView, cell: cell)
            return
        } else {
            let tag = tags[indexPath.row - 1]
            
            browseDelegate?.browseWordsWithTag(withTag: tag, atRect: cellFrameInSuperView, cell: cell)
        }
        
    }
}
