//
//  SpeechUtility.swift
//  Enfoca
//
//  Created by Trevis Thomas on 8/2/17.
//  Copyright © 2017 Trevis Thomas. All rights reserved.
//

import Foundation
import Speech

class SpeechUtility {
    
    private var speechRecognizer : SFSpeechRecognizer!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    init(language: String, callback: @escaping (SFSpeechRecognizerAuthorizationStatus)->()){
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
        
        SFSpeechRecognizer.requestAuthorization { (authStatus:SFSpeechRecognizerAuthorizationStatus) in
            invokeLater {
                callback(authStatus)
            }
        }
    }
    
    
    
//    override func viewDidAppear(_ animated: Bool) {
//        speechRecognizer.delegate = self
//        
//        SFSpeechRecognizer.requestAuthorization { authStatus in
//            /*
//             The callback may not be called on the main thread. Add an
//             operation to the main queue to update the record button's state.
//             */
//            OperationQueue.main.addOperation {
//                switch authStatus {
//                case .authorized:
//                    self.recordButton.isEnabled = true
//                    
//                case .denied:
//                    self.recordButton.isEnabled = false
//                    self.recordButton.setTitle("User denied access to speech recognition", for: .disabled)
//                    
//                case .restricted:
//                    self.recordButton.isEnabled = false
//                    self.recordButton.setTitle("Speech recognition restricted on this device", for: .disabled)
//                    
//                case .notDetermined:
//                    self.recordButton.isEnabled = false
//                    self.recordButton.setTitle("Speech recognition not yet authorized", for: .disabled)
//                }
//            }
//        }
//    }
//    
    func startRecording(callback: @escaping (String)->()) throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else { fatalError("Audio engine has no input node") }
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        
        // Configure request so that results are returned before audio recording is finished
        recognitionRequest.shouldReportPartialResults = true
        
        // A recognition task represents a speech recognition session.
        // We keep a reference to the task so that it can be cancelled.
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                callback(result.bestTranscription.formattedString)
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        try audioEngine.start()
        
    }
    
    // MARK: SFSpeechRecognizerDelegate
//    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
//        if available {
//            recordButton.isEnabled = false
//            recordButton.setTitle("Recognition not available", for: .disabled)
//        } else {
//            recordButton.isEnabled = true
//            self.recordButton.setTitle(self.verbiage["recButton"], for: [])
//        }
//    }
    
    
//    @IBAction func talkButton(_ sender: AnyObject) {
//        
//        if audioEngine.isRunning {
//            self.stopRecording()
//        } else {
//            try! startRecording()
//            self.recordButton.setTitle(self.verbiage["recButtonStop"], for: [])
//        }
//    }
    
    func stopRecording(){
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        audioEngine.stop()
        recognitionRequest?.endAudio()
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayback)
            try audioSession.setMode(AVAudioSessionModeDefault)
            
        } catch {
            print("audioSession properties weren't reset because of an error.")
        }
        
        
    }
}
