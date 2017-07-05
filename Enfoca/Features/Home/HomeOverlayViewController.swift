//
//  OverlayViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 7/5/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

protocol HomeOverlayViewControllerDelegate {
    func browseWordsWithTag(withTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell)
    func quizWordsWithTag(withTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell)
}

class HomeOverlayViewController: UIViewController {

    @IBOutlet weak var browseQuizSegmentedControl: UISegmentedControl!
    @IBOutlet weak var tagContainerView: UIView!
    @IBOutlet weak var segmentedControlLeftConstraint: NSLayoutConstraint!
    
    fileprivate var delegate : HomeOverlayViewControllerDelegate!
    
    
    fileprivate var tagViewController: TagSelectionViewController!
//    fileprivate var homeController: HomeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeSubViews()
        initializeLookAndFeel()
    }

    
    func initialize(delegate: HomeOverlayViewControllerDelegate){
        self.delegate = delegate
    }
    
    
    private func initializeLookAndFeel(){
        
        let font = Style.segmentedControlFont()
        browseQuizSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font],
                                                        for: .normal)
    }
    
    private func initializeSubViews() {
        tagViewController = createTagSelectionViewController(inContainerView: tagContainerView)
        tagViewController.animateCollectionViewCellCreation = true
    }
    
    

}

//Public API
extension HomeOverlayViewController {
    func onTagsLoaded(tags: [Tag]) {
        tagViewController.initialize(tags: tags, browseDelegate: self)
    }
    
    
        
    
}

extension HomeOverlayViewController: BrowseTagSelectionDelegate {
    func browseWordsWithTag(withTag tag: Tag, atRect: CGRect, cell: UICollectionViewCell) {
//        print("Browse words tagged: \(tag.name)")
        
        
        if browseQuizSegmentedControl.selectedSegmentIndex == 0 {
            delegate.quizWordsWithTag(withTag: tag, atRect: atRect, cell: cell)
        } else {
            delegate.browseWordsWithTag(withTag: tag, atRect: atRect, cell: cell)
        }
        

//        browseViewFromHomeAnimator.sourceFrame = atRect
//        browseViewFromHomeAnimator.sourceCell = cell
//
//        performSegue(withIdentifier: "BrowseViewControllerSegue", sender: tag)
    }
}
