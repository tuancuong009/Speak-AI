//
//  UploadRecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 5/3/25.
//

import UIKit
import PanModal
import AVKit
import AVFoundation
extension UploadRecordingViewController: PanModalPresentable {
    var allowsDragToDismiss: Bool {
        return false
    }
    
    // 🔹 Disable tap outside to dismiss
    var allowsTapToDismiss: Bool {
        return false
    }
    
    // 🔹 Disable any animation when dismissing
    var shouldAnimateDismiss: Bool {
        return false
    }
    
    var allowsExtendedPanScrolling: Bool{
        return false
    }
    
    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }
    
    var panScrollable: UIScrollView? {
        return nil
    }
    
    var topOffset: CGFloat {
        return 0.0
    }
    
    var springDamping: CGFloat {
        return 1.0
    }
    
    var transitionDuration: Double {
        return 0.4
    }
    
    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.allowUserInteraction, .beginFromCurrentState]
    }
    
    var shouldRoundTopCorners: Bool {
        return false
    }
    
    var showDragIndicator: Bool {
        return false
    }
}

class UploadRecordingViewController: BaseViewController {
    var tapSaveLater:(()->())?
    var tapCancel:(()->())?
    var tapTranscribe:((_ model: LanguageModel?)->())?
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var btnTranscribe: UIButton!
    var indexLangage: Int = -1
    var languageModel: LanguageModel?
    var folderObj: FolderObj?
    @IBOutlet weak var lblFolder: UILabel!
    @IBOutlet weak var btnSpeed: UIButton!
    @IBOutlet weak var lblTineStart: UILabel!
    @IBOutlet weak var lblTimeEnd: UILabel!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var viewAudio: UIView!
    private var recordings = [URL]()
    private var player: AVAudioPlayer? = nil
    var mergeAudioURL: URL?
    var isPlay: Bool = false {
        didSet {
            if isPlay {
                btnPlay.isSelected = true
                self.player?.play()
                timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
                    if self.player != nil{
                        self.slider.value = Float(self.player!.currentTime)
                        self.lblTineStart.text =  TimeHelper.shared.convertTimeToSecond(Int(self.slider.value))
                        if self.player!.currentTime == 0.0
                        {
                            self.player?.stop()
                            self.isPlay = false
                            self.btnPlay.isSelected = false
                            self.lblTimeEnd.text = String(format: "00:%02d", Int(self.player!.duration) % 60)
                        }
                    }
                }
            }
            else{
                self.player?.stop()
                self.btnPlay.isSelected = false
                timer?.invalidate()
            }
        }
    }
    
    
    private var timer: Timer? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doClose(_ sender: Any) {
        self.tapCancel?()
        self.dismiss(animated: true) {
            
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let player = player, player.isPlaying{
            player.stop()
        }
    }
    @IBAction func doLangauge(_ sender: Any) {
        let vc = LanguageViewController()
        vc.languageModel = languageModel
        vc.tapLanguage = { [self] languageM, indexP in
            languageModel = languageM
            indexLangage = indexP
            lblLanguage.text = languageM.name
            AnalyticsManager.shared.trackEvent(.Transcription_Language_Selected, properties: [AnalyticsProperty.language: languageM.name])
        }
        present(vc, animated: true)
    }
    
    @IBAction func doFolder(_ sender: Any) {
        let vc = FolderRecordingViewController()
        vc.tapFolder = { [self] folder in
            folderObj = folder
            lblFolder.text = folder.name
        }
        present(vc, animated: true)
    }
    
    @IBAction func doTranscribe(_ sender: Any) {
        
        InternetChecker.isConnected { isConnected in
            if isConnected {
                self.dismiss(animated: true) {
                    AnalyticsManager.shared.trackEvent(.Recording_Saved, properties: [AnalyticsProperty.recordingDuration: "\(Int(self.slider.maximumValue)) seconds", AnalyticsProperty.transcriptionLanguage: self.lblLanguage.text!, AnalyticsProperty.folderSelected: self.lblFolder.text!, AnalyticsProperty.transcribeOption: "Transcribe Now"])
                    
                    AnalyticsManager.shared.setProperties([
                        AnalyticsProperty.recordingDuration: "\(Int(self.slider.maximumValue)) seconds",
                        AnalyticsProperty.transcriptionLanguage: self.lblLanguage.text ?? "",
                        AnalyticsProperty.folderSelected: self.lblFolder.text ?? ""
                    ])
                    
                    self.tapTranscribe?(self.languageModel)
                }
            } else {
                AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: MESSAGE_APP.NO_INTERNET, AnalyticsProperty.screen: "Detail Recording"])
                self.showMessageComback(MESSAGE_APP.NO_INTERNET) { success in
                    
                }
            }
        }
    }
       
    
    @IBAction func doSaveLater(_ sender: Any) {
        saveRecordAudio()
        AnalyticsManager.shared.trackEvent(.Recording_Saved, properties: [AnalyticsProperty.recordingDuration: "\(Int(self.slider.maximumValue)) seconds", AnalyticsProperty.transcriptionLanguage: lblLanguage.text!, AnalyticsProperty.folderSelected: lblFolder.text!, AnalyticsProperty.transcribeOption: "Save & Transcribe Later"])
        self.dismiss(animated: true) {
            self.tapSaveLater?()
        }
    }
    @IBAction func doSpeed(_ sender: Any) {
        showRateAlert()
    }
    @IBAction func doNext15s(_ sender: Any) {
        guard let player = player else { return }
        let newTime = min(player.currentTime + 15, player.duration) // Prevent exceeding duration
        player.currentTime = newTime
        self.slider.value = Float(self.player!.currentTime)
        self.lblTineStart.text =  TimeHelper.shared.convertTimeToSecond(Int(self.slider.value))
    }
    @IBAction func doPrev15s(_ sender: Any) {
        guard let player = player else { return }
        let newTime = max(player.currentTime - 15, 0) // Prevent negative time
        player.currentTime = newTime
        self.slider.value = Float(self.player!.currentTime)
        self.lblTineStart.text =  TimeHelper.shared.convertTimeToSecond(Int(self.slider.value))
    }
    
    @IBAction func changeSlider(_ sender: Any) {
        self.player?.currentTime = TimeInterval(slider.value)
    }
    
    @IBAction func doPlay(_ sender: Any) {
        isPlay = !isPlay
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
    func setPlaybackSpeed(rate: Float) {
        guard let player = player else { return }
        player.rate = rate
//        if !player.isPlaying {
//            player.play()  // Restart playback if paused to apply speed change
//        }
    }
    
    private func saveRecordAudio(){
        guard let folderObj = folderObj else {
            return
        }
        guard let mergeAudioURL = mergeAudioURL , let data = convertLocalURLToData(url: mergeAudioURL) else{
            return
        }
        let recordId = UUID().uuidString
        let record = RecordsObj(id: recordId, file: "save_record_\(recordId).m4a", createAt: Date().timeIntervalSince1970, folderId: folderObj.id, title: "Untitled Note \(AppSetings.shared.getUnititledNote())", transcription: "", emoji: "", is_later: true, is_read: false, language_code: languageModel?.code ?? "en", filesize: Double(self.getFileSize(from: mergeAudioURL) ?? Int64(0.0)))
        _ = CoreDataManager.shared.saveRecord(record: record)
       
        _ = FileManagerHelper.shared.saveFileToLocal(data: data, fileName: "save_record_\(recordId).m4a", folderName: FILE_NAME.records)
        AppSetings.shared.updateUntitled()
        NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.NEW_RECORD), object: nil)
    }
    
    private func convertLocalURLToData(url: URL) -> Data? {
        do {
            let data = try Data(contentsOf: url)
            return data
        } catch {
            print("Error converting file to Data: \(error)")
            return nil
        }
    }
    
    func getFileSize(from localURL: URL) -> Int64? {
        do {
            let resourceValues = try localURL.resourceValues(forKeys: [.fileSizeKey])
            if let fileSize = resourceValues.fileSize {
                return Int64(fileSize) // bytes
            }
        } catch {
            print("Error getting file size:", error)
        }
        return nil
    }
}

extension UploadRecordingViewController{
    private func setupUI(){
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
        if let thumbImage = UIImage(named: "dot_slider") {
            slider.setThumbImage(thumbImage, for: .normal)
        }
        btnTranscribe.layer.cornerRadius =  btnTranscribe.frame.size.height/2
        btnTranscribe.layer.masksToBounds = true
        folderObj = TempStorage.shared.folderObj
        lblFolder.text = folderObj?.name
        if mergeAudioURL == nil{
            listRecordings()
        }
        else{
            self.initRecord()
        }
        self.languageModel = LanguageAssemblyAI.shared.firstLanguage()
        if let languageModel = languageModel{
            lblLanguage.text = languageModel.name
        }
    }
    
    private func listRecordings() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            let urls = try FileManager.default.contentsOfDirectory(at: documentsDirectory,
                                                                   includingPropertiesForKeys: nil,
                                                                   options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles)
            
            self.recordings = urls.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a"
            })
            
            let sortedFiles = self.recordings.sorted { (url1, url2) -> Bool in
                return url1.path > url2.path
            }
            self.mergeAudioFiles(audioFileUrls: sortedFiles)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private  func mergeAudioFiles(audioFileUrls: [URL]) {
        let composition = AVMutableComposition()
        
        for i in 0 ..< audioFileUrls.count {
            
            let compositionAudioTrack :AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())!
            
            let asset = AVURLAsset(url: audioFileUrls[i])
            print("asset--->",asset)
            if asset.tracks(withMediaType: AVMediaType.audio).count > 0{
                let track = asset.tracks(withMediaType: AVMediaType.audio)[0]
                
                let timeRange = CMTimeRange(start: CMTimeMake(value: 0, timescale: 600), duration: track.timeRange.duration)
                do {
                    try compositionAudioTrack.insertTimeRange(timeRange, of: track, at: composition.duration)
                } catch {
                    // All other errors
                }
                
            }
            
        }
        let format = DateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        let currentFileName = "recording-\(format.string(from: Date())).m4a"
        let documentDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as NSURL
        self.mergeAudioURL = documentDirectoryURL.appendingPathComponent(currentFileName)!
        //AVFileTypeWAVE
        let assetExport = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)
        assetExport?.outputFileType = AVFileType.m4a
        assetExport?.outputURL = mergeAudioURL
        assetExport?.exportAsynchronously(completionHandler:
                                            {
            
            switch assetExport!.status
            {
            case AVAssetExportSession.Status.failed:
                print("failed")
            case AVAssetExportSession.Status.cancelled:
                print("cancelled")
            case AVAssetExportSession.Status.unknown:
                print("unknown")
            case AVAssetExportSession.Status.waiting:
                print("waiting")
            case AVAssetExportSession.Status.exporting:
                print("exporting")
            default:
                print("Audio Concatenation Complete")
            }
            self.initRecord()
            self.deleteAllRecordings()
        })
    }
    private func deleteAllRecordings() {
        
        print("\(#function)")
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let fileManager = FileManager.default
        do {
            let files = try fileManager.contentsOfDirectory(at: documentsDirectory,
                                                            includingPropertiesForKeys: nil,
                                                            options: .skipsHiddenFiles)
            print(mergeAudioURL!.lastPathComponent)
            let recordings = files.filter({ (name: URL) -> Bool in
                return name.pathExtension == "m4a" && !name.absoluteString.contains(mergeAudioURL!.lastPathComponent)
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
    private func initRecord()
    {
        do {
            let path = self.mergeAudioURL!
            //Unpacking the path string optional
            try player = AVAudioPlayer(contentsOf: path)
            player?.enableRate = true
            DispatchQueue.main.async {
                if self.player != nil{
                    self.slider.maximumValue = Float(self.player!.duration)
                    self.lblTimeEnd.text =  TimeHelper.shared.convertTimeToSecond(Int(self.player!.duration))
                }
                
            }
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
