//
//  ListenViewController.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import UIKit
import Speech

class ListenViewController: UIViewController {
    
    @IBOutlet weak var listenButton: UIButton!
    @IBOutlet weak var checkMark: CheckMarkView!
    
    private var speechUtility: SpeechUtility?
    private var language: String!
    private var phrase: String!
    private var spokenText: [String] = []
    private var verifyInProgress: Bool = false
    
    private let listenTitle = "Listen"
    private let listeningTitle = "..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        listenButton.setTitle(listenTitle, for: .normal)
        checkMark.alpha = 0
    }
    
    func initialize(language: String, phrase: String){
        self.language = language
        self.phrase = phrase
    }

    @IBAction func listenButtonToggle(_ source: Any){
        let title = listenButton.title(for: .normal)
        
        if title == listenTitle {
            //listen
            listenButton.setTitle(self.listeningTitle, for: .normal)
            
            guard let language = getAppDelegate().webService.getCurrentDictionary().language else {
                return
            }
            
            speechUtility = SpeechUtility(language: language, callback: { (authStatus:SFSpeechRecognizerAuthorizationStatus) in
                if authStatus == .authorized {
                    try! self.speechUtility?.startRecording(callback: { (spokenText: String) in
                        self.spokenText.append(spokenText)
                        self.verifySpokenText()
                    })
                } else {
                    self.speechUtility = nil
                }
            })
            
        } else {
            //stop listening
            if let speechUtility = speechUtility {
                speechUtility.stopRecording()
            }
            
            listenButton.setTitle(listenTitle, for: .normal)
        }
    }
    
    private func verifySpokenText() {
        
        print("\(spokenText) verify in progress: \(verifyInProgress)")
        
        if self.verifyInProgress {
            return
        }
        self.verifyInProgress = true
        
        delay(delayInSeconds: 1.3) {
            self.verifyInProgress = false
            self.speechUtility!.stopRecording()
            if self.spokenPhraseMatch() {
                //affirmative
                UIView.animate(withDuration: 0.15, animations: {
                    self.listenButton.alpha = 0
                    self.checkMark.alpha = 1
                }, completion: { (_: Bool) in
                    self.checkMark.checked(true, animated: true)
                    self.listenButton.setTitle(self.listenTitle, for: .normal)
                    UIView.animate(withDuration: 0.33, delay: 0.66, options: [.curveEaseInOut], animations: {
                        self.listenButton.alpha = 1
                        self.checkMark.alpha = 0
                    }, completion: { (_:Bool) in
                        self.checkMark.checked(false, animated: false)
                        //nothing
                        
                    })
                })
            } else {
                self.listenButton.setTitle(self.listenTitle, for: .normal)
                //negatve
                self.verifyInProgress = false
                self.speechUtility!.stopRecording()
                CustomAnimations.shakeAnimation(view: self.listenButton)
                
            }
        }
    }
    
    func spokenPhraseMatch() -> Bool{
        for p in spokenText {
            if p.lowercased().contains(self.phrase.lowercased()) {
                return true
            }
        }
        
        return false
    }

}
