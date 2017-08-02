//
//  TextToSpeach.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import AVFoundation

class TextToSpeech {
    private let synth = AVSpeechSynthesizer()
    private var myUtterance: AVSpeechUtterance!
    
    func speak(phrase: String, language: String?){
        //Note: AVSpeechSynthesisVoice.speechVoices() will give you a list of available voices!
        
        myUtterance = AVSpeechUtterance(string: phrase)
//        myUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        myUtterance.rate = 0.35 //Default is 0.5, min 0 max 1
        //float pitchMultiplier;  // [0.5 - 2] Default = 1
        myUtterance.pitchMultiplier = 1.0
        myUtterance.voice = AVSpeechSynthesisVoice(language: language)
        synth.speak(myUtterance)
    }
}
