//
//  RecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit
import PanModal
class RecordingViewController: UIViewController {
    var tapAgainData:(()->())?
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var bgVip: UIImageView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblPause: UILabel!
    @IBOutlet weak var stackAudio: UIStackView!
    @IBOutlet weak var lblMaxTime: UILabel!
    @IBOutlet weak var viewPremium: UIView!
    var mic: MicrophoneMonitor?
    private var numberOfSamples: Int = 60
    private var arrConstraints: [NSLayoutConstraint] = []
    private var timer: Timer?
    private var numerLimit = 60
    private var increaseTime = 0
    var isStop = false
    var isResume: Bool = false{
        didSet{
            lblPause.text = isResume ? "Resume" : "Pause"
            btnPause.setImage(isResume ? UIImage(named: "btn_resume") : UIImage(named: "btnPause"), for: .normal)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateLimitTime()
    }
    
   
    @IBAction func doPayWall(_ sender: Any) {
        if !isResume{
            isResume = true
        }
        mic?.pauseMonitoring()
        stopTimer()
        AnalyticsManager.shared.trackEvent(.Limit_CTA_Clicked, properties: [AnalyticsProperty.recordingDuration: "\(increaseTime) seconds"])
        let vc = PaywallViewController.instantiate()
        vc.typePaywall = .limitPaywall
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @IBAction func doDiscard(_ sender: Any) {
        self.showAlertDiscard(msg: "Do you want to discard?")
    }
    @IBAction func doBack(_ sender: Any) {
        self.showAlertDiscard(msg: "Do you want to discard?")
    }
    
    @IBAction func doPause(_ sender: Any) {
        if increaseTime >= numerLimit - 1 {
            
            isStop = true
            stopRecording()
        }
        else{
            if isStop{
                self.mic = MicrophoneMonitor(numberOfSamples: self.numberOfSamples)
                self.mic?.notificationCenter.addObserver(forName: NotificationKey.microNotificationKey, usingBlock: { (name, data) in
                    guard let data = data as? [Float] else { return }
                    self.config(data)
                })
                isStop = false
            }
            isResume.toggle()
            if isResume{
                stopTimer()
                mic?.pauseMonitoring()
            }
            else{
                mic?.startMonitoring()
                startTimer()
            }
        }
       
    }
    @IBAction func doStop(_ sender: Any) {
        stopRecording()
    }
    
}

extension RecordingViewController{
    private func updateLimitTime(){
        if TempStorage.shared.isPremium{
            numerLimit = 120 * 60
            lblMaxTime.text = "120:00"
        }
        else{
            numerLimit = 2 * 60
            lblMaxTime.text = "02:00"
        }
        viewPremium.isHidden = TempStorage.shared.isPremium
    }
    private func stopRecording(){
        isStop = true
        stopAll()
        let nextVC = UploadRecordingViewController.init()
        nextVC.tapSaveLater = { [] in
            AnalyticsManager.shared.trackEvent(.Save_Transcribe_Later_Clicked)
            self.tapAgainData?()
            self.navigationController?.popViewController(animated: true)
        }
        nextVC.tapTranscribe = { [] model in
            let detailVC = DetailRecordingViewController.instantiate()
            detailVC.languageModel = model
            detailVC.folderObj = nextVC.folderObj
            detailVC.mergeAudioURL = nextVC.mergeAudioURL
            detailVC.modalPresentationStyle = .fullScreen
            self.present(detailVC, animated: true)
            
        }
        let rowVC: PanModalPresentable.LayoutType = nextVC
        presentPanModal(rowVC)
    }
    
    private func deleteAllRecordings() {
        
        print("\(#function)")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            let recordings = files.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a" && !name.pathExtension.contains("save_record")
            })
            for i in 0 ..< recordings.count {
                print("removing \(recordings[i])")
                do {
                    try fileManager.removeItem(at: recordings[i])
                } catch {
                    print("could not remove \(recordings[i])")
                    print(error.localizedDescription)
                }
            }
            
        } catch {
            print("could not get contents of directory at \(documentsDirectory)")
            print(error.localizedDescription)
        }
    }
    
    private func showAlertDiscard(msg: String){
        let alert = UIAlertController(title: ConfigSettings.APP_NAME, message: msg, preferredStyle: .alert)
        let yes = UIAlertAction(title: "Yes", style: .default) { action in
            self.stopAll()
            self.deleteAllRecordings()
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(yes)
        let no = UIAlertAction(title: "No", style: .cancel) { action in
            
        }
        alert.addAction(no)
        present(alert, animated: true)
    }
    private func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    private func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
    private func setupUI(){
        bgVip.layer.cornerRadius = 16
        bgVip.layer.masksToBounds = true
        deleteAllRecordings()
        configAudio()
        startTimer()
        
    }
    
    private func configAudio(){
        self.stackAudio.spacing = 4
        self.stackAudio.axis = .horizontal
        self.stackAudio.distribution = .equalSpacing
        self.stackAudio.alignment = .center
        for _ in 1...self.numberOfSamples {
            self.setupView()
        }
        
        // Create object of microphone monitor and add observer
        self.mic = MicrophoneMonitor(numberOfSamples: self.numberOfSamples)
        
        self.mic?.notificationCenter.addObserver(forName: NotificationKey.microNotificationKey, usingBlock: { (name, data) in
            guard let data = data as? [Float] else { return }
            self.config(data)
        })
        self.mic?.startMonitoring()
    }
    
    private func config(_ soundSamples: [Float]) {
        for (index, level) in soundSamples.enumerated() {
            arrConstraints[index].constant = self.normalizeSoundLevel(level: level)
        }
        self.stackAudio.layoutIfNeeded()
    }
    private func setupView() {
        let barView = UIView()
        let width = (UIScreen.main.bounds.width - CGFloat(numberOfSamples - 1) * 4) / CGFloat(numberOfSamples)
        barView.backgroundColor = UIColor(hexString: "FE4F34")
        barView.layer.cornerRadius = width / 2
        barView.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = NSLayoutConstraint(item: barView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: width)
        let heightConstraint = NSLayoutConstraint(item: barView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 0)
        
        stackAudio.addArrangedSubview(barView)
        stackAudio.addConstraints([widthConstraint,heightConstraint])
        arrConstraints.append(heightConstraint)
    }
    
    
    private func normalizeSoundLevel(level: Float) -> CGFloat {
        guard level < 0 else { return CGFloat(0.1 * stackAudio.frame.size.height / 25) } // Check if level start
        let level = max(1, CGFloat(level) + 50) / 2 // between 0.1 and 25
        return CGFloat(level * (stackAudio.frame.size.height / 25)) // scaled to max at 300 (our height of our bar)
    }
    
    private func stopAll(){
        if !isResume{
            isResume = true
        }
        mic?.stopMonitoring()
        stopTimer()
    }
    
    @objc func updateTimer()
    {
        if increaseTime > numerLimit - 1 {
            stopRecording()
        }
        else{
            increaseTime = increaseTime + 1
            print("increaseTime--->",increaseTime)
            let (h,m,s) = self.secondsToHoursMinutesSeconds(seconds: increaseTime)
            var hour = ""
            var muti = ""
            var second = ""
            if h > 0 {
                if h > 10
                {
                    hour = "\(h)"
                }
                else{
                    hour = "0\(h)"
                }
                
            }
            if m < 10
            {
                muti = "0\(m)"
            }
            else{
                muti = "\(m)"
            }
            if s < 10
            {
                second = "0\(s)"
            }
            else{
                second = "\(s)"
            }
            if hour.isEmpty
            {
                self.lblTime.text =  muti + ":" + second
            }
            else{
                self.lblTime.text =  hour + ":" + muti + ":" + second
            }
        }
        
    }
    
    private func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
}
