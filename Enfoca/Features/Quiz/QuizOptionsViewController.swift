//
//  QuizViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 6/9/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

//Why is this here? Find out who implements this!
protocol QuizViewControllerDelegate {
    func tagSelectedForQuiz() -> Tag
}

protocol QuizOptionsViewControllerDelegate {
    func onError(title: String, message: EnfocaError)
}

class QuizOptionsViewController: UIViewController {
    private var delegate : QuizViewControllerDelegate!
    
    @IBOutlet weak var cardSideSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet weak var headerBackgroundView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var browseButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topToHeaderBottomConstraint: NSLayoutConstraint!
    
    fileprivate var viewModel : QuizOptionsViewModel!
    fileprivate let quizOptionsToCardFrontViewAnimator = QuizOptionsToCardFrontViewAnimator()
    
    private var showBrowseButton: Bool = false
    
    @IBAction func incrementWordCountAction(_ sender: UIButton) {
        viewModel.incrementWordCount()
        formatWordCountText()
    }
    
    func initialize(delegate: QuizViewControllerDelegate, showBackButton: Bool = false) {
        self.delegate = delegate
        self.showBrowseButton = showBackButton
    }
    
    @IBAction func cardSideSegmentedControlValueChanged(_ sender: UISegmentedControl) {
        viewModel.cardSide = CardSide.values[sender.selectedSegmentIndex]
    }
    
    @IBAction func decrementWordCountAction(_ sender: UIButton) {
        viewModel.decrementWordCount()
        formatWordCountText()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = QuizOptionsViewModel(tag: delegate.tagSelectedForQuiz(), delegate: self)
        
        initializeLookAndFeel()
    }
    
    private func initializeLookAndFeel(){
        let font = Style.segmentedControlFont()
        cardSideSegmentedControl.setTitleTextAttributes([NSFontAttributeName: font], for: .normal)
        cardSideSegmentedControl.selectedSegmentIndex = CardSide.values.index(of: viewModel.cardSide)!
        titleLabel.text = viewModel.tagName
        
        cardSideSegmentedControl.setTitle(getTermTitle(), forSegmentAt: 2)
        cardSideSegmentedControl.setTitle(getDefinitionTitle(), forSegmentAt: 0)
        
        browseButton.isHidden = !showBrowseButton
        
        formatWordCountText()
    }
    
    private func formatWordCountText() {
        wordCountLabel.text = "Word Count: \(viewModel.wordCount!)"
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        dismiss(animated: true) {
            //whatever
        }
    }
    
    @IBAction func browseButonAction(_ sender: Any) {
        performSegue(withIdentifier: "BrowseSegue", sender: nil)
    }
   
    @IBAction func cancelAction(_ sender: EnfocaButton) {
        dismiss(animated: true) { 
            //whatever
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let to = segue.destination as? CardFrontViewController {
            to.initialize(viewModel: viewModel)
            to.transitioningDelegate = self
        } else if let to = segue.destination as? BrowseViewController {
            //Trevis: Notice that when you go straignt from Quiz Options to Browse that you use the app defaults word order, not necessairly the selection on the home view.
            to.initialize(tag: viewModel.tag, wordOrder: getAppDelegate().applicationDefaults.wordPairOrder)
        }
    }
    
    @IBAction func startQuizAction(_ sender: EnfocaButton) {
        
        switch (sender.titleLabel!.text!) {
        case "Random":
            viewModel.cardOrder = CardOrder.random
        case "Hardest":
            viewModel.cardOrder = CardOrder.hardest
        case "Least Studied":
            viewModel.cardOrder = CardOrder.leastStudied
        case "Recently Added":
            viewModel.cardOrder = CardOrder.latestAdded
        default: fatalError()
        }
        
        print("Quiz: \(viewModel.tagName) Words: \(viewModel.wordCount) Card Order: \(viewModel.cardOrder) Card Side: \(viewModel.cardSide)")
        
        viewModel.startQuiz { 
            self.performSegue(withIdentifier: "BeginQuizSegue", sender: self)
        }
    }
   

}


extension QuizOptionsViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.cardOrder = CardOrder.values[row]
    }
}

extension QuizOptionsViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return CardOrder.values.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return CardOrder.values[row].rawValue
    }
}

extension QuizOptionsViewController: EnfocaHeaderViewAnimationTarget {
    func getView() -> UIView {
        return view
    }
    func getHeaderBackgroundView() -> UIView {
        return headerBackgroundView
    }
}

extension QuizOptionsViewController: QuizOptionsViewControllerDelegate {
    func onError(title: String, message: EnfocaError) {
        self.onError(title: title, message: message)
    }
}

//For animated transitions
extension QuizOptionsViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if let _ = presented as? CardFrontViewController, let _ = source as? QuizOptionsViewController {
            quizOptionsToCardFrontViewAnimator.presenting = true
            return quizOptionsToCardFrontViewAnimator
        }
        
        
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        return nil
    }
}


