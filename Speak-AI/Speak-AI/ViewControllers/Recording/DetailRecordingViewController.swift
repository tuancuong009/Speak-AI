//
//  DetailRecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit
import UIKit
import AVFoundation
import PanModal
import Alamofire
import SkeletonView
extension DetailRecordingViewController: PanModalPresentable {
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

class DetailRecordingViewController: BaseViewController {
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    var player: AVAudioPlayer? = nil
    var mergeAudioURL: URL?
    private var isPlay: Bool = false
    var timer: Timer? = nil
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var cltMenu: UICollectionView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnSpeed: UIButton!
    @IBOutlet weak var naviLabel: UILabel!
    var pageMenu: CAPSPageMenu?
    var controllers: [UIViewController] = []
    var languageModel: LanguageModel?
    var folderObj: FolderObj?
    var processRecordingViewController: ProcessRecordingViewController?
    private var arrMenus: [ActionAI] = [.transcription]
    private var arrControllerTabs: [TranscripitonViewController] = []
    private var indexMenu = 0
    private var transcriptionText = ""
    private var summaryText = ""
    var recordId = ""
    var recordObj: RecordsObj?
    @IBOutlet weak var btnGenerate: UIButton!
    @IBOutlet weak var heightContentPage: NSLayoutConstraint!
    @IBOutlet weak var viewAudio: UIView!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var viewSketon: UIView!
    @IBOutlet weak var lblSketon: UILabel!
    
    var timerProcess: Timer?
    var currentSecond = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func registerTimerProgress(){
        currentSecond = 0
                
        timerProcess?.invalidate()
        timerProcess = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentSecond += 1
        }
    }
    
    @IBAction func doMore(_ sender: Any) {
        InternetChecker.isConnected { isConnected in
            if isConnected {
                let nextVC = AllOptionRecordingViewController.instantiate()
                nextVC.tapAction = { [self] action in
                    validActionTab(action: action)
                }
                let rowVC: PanModalPresentable.LayoutType = nextVC
                self.presentPanModal(rowVC)
            } else {
                AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: MESSAGE_APP.NO_INTERNET, AnalyticsProperty.screen: "Detail Recording"])
                self.showMessageComback(MESSAGE_APP.NO_INTERNET) { success in
                    
                }
            }
        }
    }
    
    @IBAction func doBack(_ sender: Any) {
        stopPlayer()
        removeNotification()
        APP_DELEGATE.detailHomeViewController = nil
        APP_DELEGATE.initHome()
    }
    
    @IBAction func doOption(_ sender: Any) {
        let nextVC = OptionRecordingViewController.instantiate()
        nextVC.tapOption = { [self] action in
            if action == .deleteNote{
                showActionDeleteNote()
            }
            else if action == .exportAudio{
                guard let mergeAudioURL = mergeAudioURL else{
                    return
                }
                exportShareAudio(mergeAudioURL)
            }
            else if action == .shareSummary{
                AnalyticsManager.shared.trackEvent(.Content_Shared, properties: [AnalyticsProperty.contentType: "Summary"])
                shareText(self.summaryText)
            }
            else if action == .shareTransacription{
                AnalyticsManager.shared.trackEvent(.Content_Shared, properties: [AnalyticsProperty.contentType: "Transacription"])
                shareText(self.transcriptionText)
            }
            else if action == .exportPDF{
                if indexMenu > arrControllerTabs.count - 1{
                    return
                }
                let controller = arrControllerTabs[indexMenu]
                let nameFile = (self.recordObj?.title ?? "exportfile") + "_\(self.arrMenus[indexMenu])"
                if let pdfURL = createPDF(from: controller.lblDesc.attributedText ?? NSAttributedString.init(), fileName: nameFile) {
                    print("PDF saved at: \(pdfURL)")
                    AnalyticsManager.shared.trackEvent(.PDF_Exported, properties: [AnalyticsProperty.exportNoteAsPDF: "Full Transcription and Summary"])
                    self.exportShareAudio(pdfURL)
                }
            }
            else if action == .moveFolder{
                let vc = FolderRecordingViewController()
                vc.tapFolder = { [self] folder in
                    folderObj = folder
                    _ = CoreDataManager.shared.updateFolderRecord(recordID: recordId, folderId: folder.id)
                }
                present(vc, animated: true)
            }
        }
        let rowVC: PanModalPresentable.LayoutType = nextVC
        presentPanModal(rowVC)
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
    
    @IBAction func doGenrete(_ sender: Any) {
        InternetChecker.isConnected { isConnected in
            if isConnected {
                guard let recordObj = self.recordObj else{
                    return
                }
                self.showProgressUploadUploadFileLater(recordObj)
            } else {
                AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: MESSAGE_APP.NO_INTERNET, AnalyticsProperty.screen: "Detail Recording"])
                self.showMessageComback(MESSAGE_APP.NO_INTERNET) { success in
                    
                }
            }
        }
       
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
        print("Rate-->",rate)
        guard let player = player else { return }
        player.rate = rate
//        if !player.isPlaying {
//            player.play()  // Restart playback if paused to apply speed change
//        }
    }
    
    private func skeletonView(isShow: Bool){
        titleLabel.isSkeletonable = true
        cltMenu.isSkeletonable = true
        lblSketon.isSkeletonable = true
        lblSketon.showSkeleton()
        if isShow{
            titleLabel.showSkeleton()
            cltMenu.showSkeleton()
        }
        else{
            titleLabel.hideSkeleton()
            cltMenu.hideSkeleton()
        }
    }
    
}

extension DetailRecordingViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMenus.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cltMenu.dequeueReusableCell(withReuseIdentifier: "MenuHomeCollect", for: indexPath) as! MenuHomeCollect
        cell.lblname.text = arrMenus[indexPath.row].name
        cell.viewSelect.isHidden = indexPath.row == indexMenu ? false : true
        cell.lblname.font = UIFont(name: indexPath.row == indexMenu ? "Inter-SemiBold" : "Inter-Regular", size: 14.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexMenu = indexPath.row
        cltMenu.reloadData()
        cltMenu.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageMenu?.moveToPage(indexMenu)
        updateHeightPageTab()
    }
}

extension DetailRecordingViewController{
    private func exportShareAudio(_ url: URL){
        let text = url
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private func shareText(_ text: String){
        
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    func createPDF(from attributedText: NSAttributedString, fileName: String) -> URL? {
        let name = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        let pdfFileName = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).pdf")
        
        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 20
        let textWidth = pageWidth - 2 * margin
        let textHeight = pageHeight - 2 * margin
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        // Setup text system
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: pageRect)

        do {
            try pdfRenderer.writePDF(to: pdfFileName) { context in
                var pageRangeStart = 0

                while pageRangeStart < layoutManager.numberOfGlyphs {
                    context.beginPage()
                    
                    let textContainer = NSTextContainer(size: CGSize(width: textWidth, height: textHeight))
                    textContainer.lineFragmentPadding = 0
                    layoutManager.addTextContainer(textContainer)
                    
                    let glyphRange = layoutManager.glyphRange(for: textContainer)
                    layoutManager.drawBackground(forGlyphRange: glyphRange, at: CGPoint(x: margin, y: margin))
                    layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: CGPoint(x: margin, y: margin))
                    
                    pageRangeStart = NSMaxRange(glyphRange)
                }
            }
            print("PDF created at: \(pdfFileName)")
            return pdfFileName
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }


    
    private func saveRecordAudio(_ transcription: String, _ title: String, _ emoji: String){
        self.titleLabel.text = emoji + " " + title
        guard let folderObj = folderObj else {
            return
        }
        guard let mergeAudioURL = mergeAudioURL , let data = convertLocalURLToData(url: mergeAudioURL) else{
            return
        }
        let record = RecordsObj(id: recordId, file: "save_record_\(recordId).m4a", createAt: Date().timeIntervalSince1970, folderId: folderObj.id, title: title, transcription: transcription, emoji: emoji, is_later: false, is_read: false, language_code: languageModel?.code ?? "en", filesize: Double(self.getFileSize(from: mergeAudioURL) ?? Int64(0.0)))
        recordObj = record
        _ = CoreDataManager.shared.saveRecord(record: record)
        
        _ = FileManagerHelper.shared.saveFileToLocal(data: data, fileName: "save_record_\(recordId).m4a", folderName: FILE_NAME.records)
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
    
    private func editRecordAudio(_ transcription: String, _ title: String, _ emoji: String){
        self.titleLabel.text = emoji + " " + title
        guard var recordObj = recordObj else {
            return
        }
        recordObj.title = title
        recordObj.transcription = transcription
        recordObj.emoji = emoji
        recordObj.is_later = false
        _ = CoreDataManager.shared.updateRecord(record: recordObj)
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
    
    private func saveRecordAction(action: ActionAI, text: String){
   
        let recordAction = RecordActionObj(action: action.rawValue, recordId: recordId, text: text, textAI: text, id: UUID().uuidString)
        _ = CoreDataManager.shared.saveRecordActions(record: recordAction)
        
    }
    
    private func showProgressUploadUploadFileLater(_ record: RecordsObj){
        let languageModel = LanguageModel(NSDictionary.init())
        languageModel.code = record.language_code
        let detailVC = ProcessRecordingViewController()
        detailVC.languageModel = languageModel
        detailVC.mergeAudioURL = self.mergeAudioURL
        processRecordingViewController = detailVC
        detailVC.tapComplete = { [] transaction, summary, title, emoji in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.viewContent.isHidden = false
            }
            self.skeletonView(isShow: false)
            self.editRecordAudio(transaction, title, emoji)
            self.transcriptionText = transaction
            self.summaryText = summary ?? ""
            self.saveRecordAction(action: .transcription, text: transaction)
            if self.arrControllerTabs.count > 0{
                let vc = self.arrControllerTabs[0]
                vc.tabDetailOpenAI.general = transaction
                vc.tabDetailOpenAI.desc = transaction
                vc.updateTranscripiton(transaction)
                self.updateHeightPageMenu()
            }
            if let summary = summary{
                self.addNewPage(action: .summary, desc: summary)
            }
            self.saveRecordAction(action: .summary, text: summary ?? "")
            self.updateLaterRecord(false)
        }
        detailVC.tapCancel = { [] in
            self.stopPlayer()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        let rowVC: PanModalPresentable.LayoutType = detailVC
        self.presentPanModal(rowVC)
    }
    
    private func showProgressUploadFile(){
        let detailVC = ProcessRecordingViewController()
        detailVC.languageModel = languageModel
        detailVC.mergeAudioURL = self.mergeAudioURL
        processRecordingViewController = detailVC
        detailVC.tapComplete = { [] transaction, summary, title, emoji in
            AnalyticsManager.shared.setProperty(key: AnalyticsProperty.processingTime, value: "\(self.currentSecond) seconds")
            AnalyticsManager.shared.setProperty(key: AnalyticsProperty.success, value: true)
            AnalyticsManager.shared.trackEventTmp(event: .Transcription_Completed)
            AnalyticsManager.shared.clearProperties()
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.viewContent.isHidden = false
            }
            self.skeletonView(isShow: false)
            self.saveRecordAudio(transaction, title, emoji)
            self.transcriptionText = transaction
            self.summaryText = summary ?? ""
            self.saveRecordAction(action: .transcription, text: transaction)
            self.updateLaterRecord(false)
            if self.arrControllerTabs.count > 0{
                let vc = self.arrControllerTabs[0]
                vc.tabDetailOpenAI.general = transaction
                vc.tabDetailOpenAI.desc = transaction
                vc.updateTranscripiton(transaction)
                self.updateHeightPageMenu()
            }
            if let summary = summary{
                self.addNewPage(action: .summary, desc: summary)
            }
            self.saveRecordAction(action: .summary, text: summary ?? "")
        }
        detailVC.tapCancel = { [] in
            self.stopPlayer()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        let rowVC: PanModalPresentable.LayoutType = detailVC
        self.presentPanModal(rowVC)
    }
    
    private func addNewPage(action: ActionAI, desc: String, isMove: Bool = false) {
        arrMenus.append(action)
        cltMenu.reloadData()
        let tabModel = tabDetailOpenAI()
        tabModel.action = action
        tabModel.general = desc
        tabModel.desc = desc
        
        let transcuibeVC  = TranscripitonViewController()
        transcuibeVC.updateTranscriptionDelegate = { [weak self] value in
            guard let self = self else{
                return
            }
            self.transcriptionText = value
            recordObj?.transcription = value
        }
        transcuibeVC.detailHomeViewController = self
        transcuibeVC.tabDetailOpenAI = tabModel
        arrControllerTabs.append(transcuibeVC)
        pageMenu?.view.removeFromSuperview()
        
        // Khởi tạo lại PageMenu với danh sách mới
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        pageMenu = CAPSPageMenu(viewControllers: arrControllerTabs, frame: CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: viewContent.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = false
        viewContent.addSubview(pageMenu!.view)
        if isMove{
            pageMenu?.moveToPage(arrMenus.count - 1)
        }
    }
    
    private func getAllActionRecord(record: RecordsObj){
        let actionRecords = CoreDataManager.shared.fetchRecordActions(recordId: record.id)
        setUpPageMenuAllActionLocals(recordActions: actionRecords)
        if actionRecords.count > 0{
            self.summaryText = actionRecords[1].text
        }
        
    }
    private func getSummary(action: ActionAI, completion: @escaping (String?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(ConfigAOpenAI.Summaries)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are an expert summarizer."],
                ["role": "user", "content": action.promptFormat(text: transcriptionText)]
            ],
            "temperature": 0.5
        ]
        print("Param--->",parameters)
        AF.request(ConfigAOpenAI.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .downloadProgress { progress in
                
                
            }
            .responseDecodable(of: OpenAIResponse.self) { response in
                switch response.result {
                case .success(let openAIResponse):
                    if let summary = openAIResponse.choices.first?.message.content {
                        print("✅ Summary: \(summary)")
                        completion(summary)
                    } else {
                        print("❌ No summary found")
                        completion(nil)
                    }
                case .failure(let error):
                    print("❌ Error: \(error)")
                    completion(nil)
                }
            }
    }
    
    func validActionTab(action: ActionAI){
        if let index = arrMenus.firstIndex(of: action) {
            print("Index is \(index)")  // Output: Index of 30 is 2
            pageMenu?.moveToPage(index)
        } else {
            print("Not found")
            AnalyticsManager.shared.trackEvent(.AI_Action_Used, properties: [AnalyticsProperty.actionType: action.name, AnalyticsProperty.language: languageModel?.name ?? ""])
            showBusy()
            getSummary(action: action) { value in
                self.hideBusy()
                if let value = value{
                    self.addNewPage(action: action, desc: value, isMove: true)
                    self.saveRecordAction(action: action, text: value)
                    self.updateHeightPageMenu()
                }
            }
        }
    }
    private func showActionDeleteNote(){
        let alert = UIAlertController.init(title: "", message: "Are you sure you want to delete this?", preferredStyle: .actionSheet)
        let actionDelete =  UIAlertAction(title: "Delete Note", style: .destructive) { action in
            AnalyticsManager.shared.trackEvent(.Note_Deleted)
            _ = CoreDataManager.shared.deleteRecord(withID: self.recordId)
            _ = CoreDataManager.shared.deleteRecordActions(withID: self.recordId)
            if let recordObj = self.recordObj{
                FileManagerHelper.shared.deleteFile(fileName: recordObj.file, folderName: FILE_NAME.records)
            }
            self.stopPlayer()
            self.removeNotification()
            APP_DELEGATE.detailHomeViewController = nil
            APP_DELEGATE.initHome()
        }
        alert.addAction(actionDelete)
        
        let actionCancel =  UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
    
    func covertToFileString(with size: UInt64) -> String {
        var convertedValue: Double = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1024 {
            convertedValue /= 1024
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }
    
    private func stopPlayer(){
        player?.stop()
        player = nil
        timer?.invalidate()
        timer = nil
    }
    
    private func setupUI(){
        registerNotification()
        APP_DELEGATE.detailHomeViewController = self
        
        if let thumbImage = UIImage(named: "dot_slider") {
            slider.setThumbImage(thumbImage, for: .normal)
        }
        self.initRecord()
        if let recordObj = recordObj{
            recordId = recordObj.id
            if recordObj.is_later{
                setUpPageMenu()
                viewContent.isHidden = true
                titleLabel.text = recordObj.title
                skeletonView(isShow: true)
                titleLabel.hideSkeleton()
                updateLaterRecord(true)
            }
            else{
                updateLaterRecord(false)
                transcriptionText = recordObj.transcription
                titleLabel.text = recordObj.emoji + " " + recordObj.title
                getAllActionRecord(record: recordObj)
            }
        }
        else{
            viewContent.isHidden = true
            updateLaterRecord(false)
            viewSketon.isHidden = false
            setUpPageMenu()
            recordId = UUID().uuidString
            skeletonView(isShow: true)
            let seconds = 0.25
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.registerTimerProgress()
                self.showProgressUploadFile()
            }
        }
    }
    
    private func updateLaterRecord(_ isLater: Bool){
        if isLater{
            btnOption.isHidden = true
            btnAction.isHidden = true
            btnGenerate.isHidden = false
            viewSketon.isHidden = false
        }
        else{
            btnOption.isHidden = false
            btnAction.isHidden = false
            btnGenerate.isHidden = true
            viewSketon.isHidden = true
        }
    }
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(updateHeightPageMenu), name: NSNotification.Name(NotificationDefineName.EDIT_TEXT), object: nil)
    }
    
    private func removeNotification(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(NotificationDefineName.EDIT_TEXT), object: nil)
    }
    
    private func setUpPageMenu()
    {
        arrControllerTabs.removeAll()
        for item in arrMenus{
            let tabModel = tabDetailOpenAI()
            tabModel.action = item
            let transcuibeVC  = TranscripitonViewController()
            transcuibeVC.updateTranscriptionDelegate = { [weak self] value in
                guard let self = self else{
                    return
                }
                self.transcriptionText = value
                recordObj?.transcription = value
            }
            transcuibeVC.detailHomeViewController = self
            transcuibeVC.tabDetailOpenAI = tabModel
            arrControllerTabs.append(transcuibeVC)
            
        }
        
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        self.pageMenu = CAPSPageMenu(viewControllers: arrControllerTabs, frame: CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: viewContent.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = false
        viewContent.addSubview(pageMenu!.view)
    }
    
    private func setUpPageMenuAllActionLocals(recordActions: [RecordActionObj])
    {
        arrControllerTabs.removeAll()
        arrMenus.removeAll()
        for item in recordActions{
            arrMenus.append(ActionAI(rawValue: item.action) ?? .transalte)
            let tabModel = tabDetailOpenAI()
            tabModel.action = ActionAI(rawValue: item.action) ?? .transalte
            tabModel.desc = item.text
            tabModel.general = item.textAI
            let transcuibeVC  = TranscripitonViewController()
            transcuibeVC.updateTranscriptionDelegate = { [weak self] value in
                guard let self = self else{
                    return
                }
                self.transcriptionText = value
                recordObj?.transcription = value
            }
            transcuibeVC.detailHomeViewController = self
            transcuibeVC.tabDetailOpenAI = tabModel
            arrControllerTabs.append(transcuibeVC)
            
        }
        cltMenu.reloadData()
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        self.pageMenu = CAPSPageMenu(viewControllers: arrControllerTabs, frame: CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: viewContent.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = false
        viewContent.addSubview(pageMenu!.view)
        updateHeightPageMenu()
    }
    
    
    func initRecord()
    {
        do {
            let path = self.mergeAudioURL!
            try player = AVAudioPlayer(contentsOf: path)
            player?.enableRate = true
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
    
    func calculateLabelHeight(attributedText: NSAttributedString, width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
        
        let boundingBox = attributedText.boundingRect(
            with: maxSize,
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )
        
        return ceil(boundingBox.height) // Làm tròn để tránh bị cắt chữ
    }
    
    @objc public func updateHeightPageMenu(){
        if indexMenu > arrControllerTabs.count - 1{
            return
        }
        let controller = arrControllerTabs[indexMenu]
        
        
        let labelHeight = controller.lblDesc.calculateHeightForAttributedText(width: UIScreen.main.bounds.size.width - 70)
        print("labelHeight--->",labelHeight)
        heightContentPage.constant = labelHeight + 150
        // self.pageMenu?.view.frame = CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: heightContentPage.constant)
        view.layoutIfNeeded()
    }
    
    
    public func updateHeightPageTab(){
        if indexMenu > arrControllerTabs.count - 1{
            return
        }
        let controller = arrControllerTabs[indexMenu]
        
        let labelHeight = controller.lblDesc.calculateHeightForAttributedText(width: UIScreen.main.bounds.size.width - 70)
        print("labelHeight TEXXXT--->",labelHeight)
        heightContentPage.constant = labelHeight + 150
        //self.pageMenu?.view.frame = CGRect(x: 0, y: 0, width: viewContent.frame.size.width, height: heightContentPage.constant)
        view.layoutIfNeeded()
    }
}


extension DetailRecordingViewController: CAPSPageMenuDelegate{
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        indexMenu = index
        cltMenu.reloadData()
        cltMenu.scrollToItem(at: IndexPath(row: indexMenu, section: 0), at: .centeredHorizontally, animated: true)
        if var recordObj = recordObj, !recordObj.is_read{
            recordObj.is_read = true
            _ = CoreDataManager.shared.updateReadRecord(withID: recordObj.id)
        }
        // self.updateHeightPageTab()
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        
    }
}

extension DetailRecordingViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > titleLabel.frame.size.height + 10 {
            naviLabel.text = titleLabel.text!.trimmed
            naviLabel.isHidden = false
        }
        else{
            naviLabel.isHidden = true
        }
    }
}
