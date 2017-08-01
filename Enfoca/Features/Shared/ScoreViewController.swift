//
//  ScoreViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/1/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {
    @IBOutlet weak var animatedCircleView: AnimatedCircleView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var score: Double!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func initialize(score: Double) {
        self.score = score
    }
    
    override func viewWillAppear(_ animated: Bool) {
        delay(delayInSeconds: 0.5) { 
            self.showScore()
        }
    }
    
    private func showScore() {
        animatedCircleView.showScore(self.score, animated: true)
        
        let growthInterval: Double = 10.0
        var currentScore: Double = self.score / growthInterval
        self.scoreLabel.text = currentScore.asPercent
        
        let interval = animatedCircleView.duration / growthInterval
        
        perSecondTimer(interval: interval) { () -> (Bool) in
            currentScore += (self.score / growthInterval)
            
            self.scoreLabel.text = min(currentScore, self.score).asPercent
            
            if currentScore < self.score {
                return true
            } else {
                CustomAnimations.bounceAnimation(view: self.view)
                return false
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
