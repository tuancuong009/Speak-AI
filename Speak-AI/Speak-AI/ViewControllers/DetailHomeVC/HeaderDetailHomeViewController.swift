//
//  HeaderDetailHomeViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 20/3/25.
//

import UIKit
import AVFoundation
class HeaderDetailHomeViewController: UIViewController {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var btnSpeed: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewAudio: UIView!
    var player: AVAudioPlayer? = nil
    var mergeAudioURL: URL?
    private var isPlay: Bool = false
    var timer: Timer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        skeletonView(isShow: true)
        if let thumbImage = UIImage(named: "dot_slider") {
            slider.setThumbImage(thumbImage, for: .normal)
        }
        self.initRecord()
      
    }
    
    @IBAction func doPlay(_ sender: Any) {
        if !isPlay {
            isPlay = true
            btnPlay.isSelected = true
            self.player?.play()
            timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                if self.player != nil{
                    self.slider.value = Float(self.player!.currentTime)
                    self.lblStartTime.text =  TimeHelper.shared.convertTimeToSecond(Int(self.slider.value))
                    if self.player!.currentTime == 0.0
                    {
                        self.player?.stop()
                        self.isPlay = false
                        self.btnPlay.isSelected = false
                        self.lblEndTime.text = String(format: "00:%02d", Int(self.player!.duration) % 60)
                    }
                }
            }
        }
        else{
            self.player?.stop()
            isPlay = false
            self.btnPlay.isSelected = false
            timer?.invalidate()
        }
    }
    
    @IBAction func changeSlider(_ sender: Any) {
        self.player?.currentTime = TimeInterval(slider.value)
    }
    
    @IBAction func doSpeed(_ sender: Any) {
        showRateAlert()
    }
    @IBAction func doNext15s(_ sender: Any) {
        guard let player = player else { return }
        let newTime = min(player.currentTime + 15, player.duration) // Prevent exceeding duration
        player.currentTime = newTime
        self.slider.value = Float(self.player!.currentTime)
        self.lblStartTime.text =  TimeHelper.shared.convertTimeToSecond(Int(self.slider.value))
    }
    @IBAction func doPrev15s(_ sender: Any) {
        guard let player = player else { return }
        let newTime = max(player.currentTime - 15, 0) // Prevent negative time
        player.currentTime = newTime
        self.slider.value = Float(self.player!.currentTime)
        self.lblStartTime.text =  TimeHelper.shared.convertTimeToSecond(Int(self.slider.value))
    }
    
    private func showRateAlert() {
        let alert = UIAlertController(title: "Select Playback Speed", message: nil, preferredStyle: .actionSheet)
        
        let rates: [(String, Float)] = [("0.5x", 0.5), ("1.0x", 1.0), ("1.5x", 1.5), ("2.0x", 2.0)]
        
        for (title, rate) in rates {
            let action = UIAlertAction(title: title, style: .default) { _ in
                self.setPlaybackSpeed(rate: rate)
                self.btnSpeed.setTitle(title, for: .normal)
            }
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // Set playback speed
    private func setPlaybackSpeed(rate: Float) {
        guard let player = player else { return }
        player.rate = rate
        if !player.isPlaying {
            player.play()  // Restart playback if paused to apply speed change
        }
    }
    
    func stopPlayer(){
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
    }
    
    func skeletonView(isShow: Bool){
        titleLabel.isSkeletonable = true
        if isShow{
            titleLabel.showSkeleton()
        }
        else{
            titleLabel.hideSkeleton()
        }
    }
    
    func initRecord()
    {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        
        do {
            let path = self.mergeAudioURL!
            try player = AVAudioPlayer(contentsOf: path)
            DispatchQueue.main.async {
                if self.player != nil{
                    self.slider.maximumValue = Float(self.player!.duration)
                    self.lblEndTime.text =  TimeHelper.shared.convertTimeToSecond(Int(self.player!.duration))
                }
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
