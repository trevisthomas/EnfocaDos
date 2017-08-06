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
    
    private var recorder: AVAudioRecorder!
    private var timer: Timer?
    private var levelsHandler: ((Float)->Void)?
    
    private let url = URL(fileURLWithPath: "/dev/null", isDirectory: true)
    private let settings: [String: Any] = [
        AVSampleRateKey: 44100.0,
        AVNumberOfChannelsKey: 1,
        AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
        AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
    ]

    
    init(language: String, callback: @escaping (SFSpeechRecognizerAuthorizationStatus)->()){
        
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))!
        
        SFSpeechRecognizer.requestAuthorization { (authStatus:SFSpeechRecognizerAuthorizationStatus) in
            invokeLater {
                callback(authStatus)
            }
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            //AVAudioSessionCategoryPlayAndRecord
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
            try recorder = AVAudioRecorder(url: url, settings: settings)
            
            
        } catch {
            print("Couldn't initialize the mic input")
        }
        
        if let recorder = recorder {
            //start observing mic levels
            recorder.prepareToRecord()
            recorder.isMeteringEnabled = true
        }
        
    }
    
    func startRecording(callback: @escaping (String)->(), levelHandler: @escaping (Float)->()) throws {
        
        // Cancel the previous task if it's running.
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
//        let audioSession = AVAudioSession.sharedInstance()
//        //AVAudioSessionCategoryPlayAndRecord
//        try audioSession.setCategory(AVAudioSessionCategoryRecord)
//        try audioSession.setMode(AVAudioSessionModeMeasurement)
//        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        
        
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
        
//        startMonitoringLevels { (level: Float) in
//            print("Mic level \(level)")
//        }
        
        startMonitoringLevels(levelHandler)
        
    }
    
    func stopRecording(){
        
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        stopMonitoringLevels()
        
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
    
    private func startMonitoringLevels(_ handler: ((Float)->Void)?) {
        levelsHandler = handler
        
        if timer == nil {
            //start meters
            timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(SpeechUtility.handleMicLevel(_:)), userInfo: nil, repeats: true)
        }
        
        recorder.record()
    }
    
    private func stopMonitoringLevels() {
        levelsHandler = nil
        //For some reason, if i stop the timer, the app crashes if you try do voice recognition.  So im just leaving the monitor active until the view is destroyed

//        timer?.invalidate()
        recorder.stop()
    }
    
    @objc private func handleMicLevel(_ timer: Timer) {
        recorder.updateMeters()
        // -160db to 0db
        let rawLevel = recorder.averagePower(forChannel: 0)
        
        //Scalling it.
        let scaledLevel = max(1, (rawLevel + 60)) / 60
        
        levelsHandler?(scaledLevel)
    }
    
    deinit {
        timer?.invalidate() //This was a hack beause stopping it without
        stopRecording()
    }
}
