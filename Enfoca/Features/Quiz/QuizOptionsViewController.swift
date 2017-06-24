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
    var delegate : QuizViewControllerDelegate!
    
    @IBOutlet weak var cardSideSegmentedControl: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var wordCountLabel: UILabel!
    @IBOutlet var headerBackgroundView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var topToHeaderBottomConstraint: NSLayoutConstraint!
    
    fileprivate var viewModel : QuizOptionsViewModel!
    fileprivate let quizOptionsToCardFrontViewAnimator = QuizOptionsToCardFrontViewAnimator()
    
    @IBAction func incrementWordCountAction(_ sender: UIButton) {
        viewModel.incrementWordCount()
        formatWordCountText()
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
   
    @IBAction func cancelAction(_ sender: EnfocaButton) {
        dismiss(animated: true) { 
            //whatever
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let cardFrontViewController = segue.destination as? CardFrontViewController else { fatalError() }
        
        cardFrontViewController.initialize(viewModel: viewModel)
        cardFrontViewController.transitioningDelegate = self
    }
    
    @IBAction func startQuizAction(_ sender: EnfocaButton) {
        
        switch (sender.titleLabel!.text!) {
        case "Random":
            viewModel.cardOrder = CardOrder.random
        case "Hardest":
            viewModel.cardOrder = CardOrder.random
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
        print("Presenting \(presenting.description)")
        
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


