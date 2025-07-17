//
//  NotificationKey.swift
//  Speak-AI
//
//  Created by QTS Coder on 10/2/25.
//




import Foundation
import AVFoundation

enum NotificationKey {
    static let microNotificationKey = "microphone.recording"
}

final class MicrophoneMonitor {
    
    let notificationCenter = MyNotificationCenter()
    
    // 1
    private var audioRecorder: AVAudioRecorder
    private var timer: Timer?
    
    private var currentSample: Int
    private let numberOfSamples: Int
    
    // 2
    var soundSamples: [Float] {
        didSet {
            self.notificationCenter.postNotification(forName: NotificationKey.microNotificationKey, forData: self.soundSamples)
            
        }
    }
  

    init?(numberOfSamples: Int) {
        self.numberOfSamples = numberOfSamples
        self.soundSamples = [Float](repeating: .zero, count: numberOfSamples)
        self.currentSample = 0
        
        // 3
        let audioSession = AVAudioSession.sharedInstance()
        
        
        // 4
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        let url = URL.init(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]).appendingPathComponent(currentFileName)
        let recorderSettings: [String:Any] = [
            AVFormatIDKey: NSNumber(value: kAudioFormatAppleLossless),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue
        ]
        
        // 5
        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: recorderSettings)
           // try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord, mode: AVAudioSessionModeVoiceChat, options: AVAudioSessionCategoryOptions.mixWithOthers)
             //       try audioSession.overrideOutputAudioPort(.none)
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
    
            //startMonitoring()
            //return nil
        } catch {
            return nil
        }
    }
    
    // 6
    func startMonitoring() {
        print("startMonitoring")
        audioRecorder.isMeteringEnabled = true
        audioRecorder.record()
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true, block: { (timer) in
            // 7
            self.audioRecorder.updateMeters()
            self.soundSamples[self.currentSample] = self.audioRecorder.averagePower(forChannel: 0)
            self.currentSample = (self.currentSample + 1) % self.numberOfSamples
            if (timer.timeInterval == 2.0) {
                timer.invalidate()
                self.audioRecorder.stop()
            }
        })
    }
    func stopMonitoring() {
        timer?.invalidate()
        audioRecorder.stop()
    }
    
    func pauseMonitoring() {
        timer?.invalidate()
        audioRecorder.pause()
    }
    // 8
    deinit {
        timer?.invalidate()
        audioRecorder.stop()
    }
}
