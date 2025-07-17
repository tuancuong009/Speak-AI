//
//  DetailHomeViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 20/3/25.
//

import UIKit
import PanModal
class DetailHomeViewController: UIViewController {
    @IBOutlet weak var naviLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnAction: UIButton!
    private var  headerDetailHomeViewController:HeaderDetailHomeViewController?
    private var actionRecordViewController: ActionRecordViewController?
    var languageModel: LanguageModel?
    var mergeAudioURL: URL?
    var transcriptionText = ""
    var summaryText = ""
    var recordId = ""
    var recordObj: RecordsObj?
    var folderObj: FolderObj?
    override func viewDidLoad() {
        super.viewDidLoad()
        configUI()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func doClose(_ sender: Any) {
        self.headerDetailHomeViewController?.stopPlayer()
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
              
                shareText(self.summaryText)
            }
            else if action == .shareTransacription{
              
                shareText(self.transcriptionText)
            }
            else if action == .exportPDF{
              
                if let pdfURL = createPDF(from: self.transcriptionText, fileName: "exportPDF") {
                    print("PDF saved at: \(pdfURL)")
                    self.exportShareAudio(pdfURL)
                }
            }
        }
        let rowVC: PanModalPresentable.LayoutType = nextVC
        presentPanModal(rowVC)
    }
    
    
    @IBAction func doAction(_ sender: Any) {
        let nextVC = AllOptionRecordingViewController.instantiate()
        nextVC.tapAction = { [self] action in
            guard let actionRecordViewController = actionRecordViewController else {
                return
            }
            actionRecordViewController.validActionTab(action: action)
        }
        let rowVC: PanModalPresentable.LayoutType = nextVC
        presentPanModal(rowVC)
    }
    
    
    private func saveRecordAudio(_ transcription: String, _ title: String, _ emoji: String){
        if let headerDetailHomeViewController = headerDetailHomeViewController {
            headerDetailHomeViewController.titleLabel.text = emoji + " " + title
        }
        guard let folderObj = folderObj else {
            return
        }
        let record = RecordsObj(id: recordId, file: "save_record_\(recordId).m4a", createAt: Date().timeIntervalSince1970, folderId: folderObj.id, title: title, transcription: transcription, emoji: emoji, is_later: false, is_read: false, language_code: languageModel?.code ?? "en")
        recordObj = record
        _ = CoreDataManager.shared.saveRecord(record: record)
        guard let mergeAudioURL = mergeAudioURL , let data = convertLocalURLToData(url: mergeAudioURL) else{
            return
        }
        _ = FileManagerHelper.shared.saveFileToLocal(data: data, fileName: "save_record_\(recordId).m4a", folderName: FILE_NAME.records)
       // NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.NEW_RECORD), object: nil)
    }
    
    private func editRecordAudio(_ transcription: String, _ title: String, _ emoji: String){
        if let headerDetailHomeViewController = headerDetailHomeViewController {
            headerDetailHomeViewController.titleLabel.text = emoji + " " + title
        }
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
    
    func saveRecordAction(action: ActionAI, text: String){
        let recordAction = RecordActionObj(action: action.rawValue, recordId: recordId, text: text, textAI: text, id: UUID().uuidString)
        _ = CoreDataManager.shared.saveRecordActions(record: recordAction)
    }
    
    
    private func showActionDeleteNote(){
        let alert = UIAlertController.init(title: "", message: "Are you sure you want to delete this?", preferredStyle: .actionSheet)
        let actionDelete =  UIAlertAction(title: "Delete Note", style: .destructive) { action in
            _ = CoreDataManager.shared.deleteRecord(withID: self.recordId)
            _ = CoreDataManager.shared.deleteRecordActions(withID: self.recordId)
            if let recordObj = self.recordObj{
                FileManagerHelper.shared.deleteFile(fileName: recordObj.file, folderName: FILE_NAME.records)
            }
            self.headerDetailHomeViewController?.stopPlayer()
            APP_DELEGATE.initHome()
            
        }
        alert.addAction(actionDelete)
        
        let actionCancel =  UIAlertAction(title: "Cancel", style: .cancel) { action in
            
        }
        alert.addAction(actionCancel)
        present(alert, animated: true)
    }
}

extension DetailHomeViewController{
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
    
    
    func createPDF(from text: String, fileName: String) -> URL? {
        var name = naviLabel.text!.trimmed
        if  let recordObj = recordObj{
            name = recordObj.title
        }
        let pdfFileName = FileManager.default.temporaryDirectory.appendingPathComponent("\(name).pdf")

        let pdfRenderer = UIGraphicsPDFRenderer(bounds: CGRect(x: 0, y: 0, width: 612, height: 792)) // Kích thước trang A4

        do {
            try pdfRenderer.writePDF(to: pdfFileName) { context in
                context.beginPage()
                let textRect = CGRect(x: 20, y: 20, width: 572, height: 752)
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 16)
                ]
                text.draw(in: textRect, withAttributes: textAttributes)
            }
            print("PDF created at: \(pdfFileName)")
            return pdfFileName
        } catch {
            print("Failed to create PDF: \(error)")
            return nil
        }
    }
}
extension DetailHomeViewController {
    
    private func configUI() {
        APP_DELEGATE.detailHomeViewController = self
        self.tp_configure(with: self, delegate: self, containerView: containerView)
        btnAction.layer.cornerRadius = btnAction.frame.size.height/2
        btnAction.layer.masksToBounds = true
        naviLabel.isHidden = true
        if let recordObj = recordObj{
            recordId = recordObj.id
            if recordObj.is_later{
                self.headerDetailHomeViewController?.skeletonView(isShow: true)
                self.actionRecordViewController?.setUpPageMenu()
                let seconds = 0.25
                DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                    self.showProgressUploadUploadFileLater(recordObj)
                }
               
            }
            else{
                self.transcriptionText = recordObj.transcription
                self.headerDetailHomeViewController?.skeletonView(isShow: false)
                self.headerDetailHomeViewController?.titleLabel.text = recordObj.emoji + " " + recordObj.title
                naviLabel.text = recordObj.emoji + " " + recordObj.title
                getAllActionRecord(record: recordObj)
            }
        }
        else{
            
            self.actionRecordViewController?.setUpPageMenu()
            recordId = UUID().uuidString
            self.headerDetailHomeViewController?.skeletonView(isShow: true)
            let seconds = 0.25
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.showProgressUploadFile()
            }
        }
    }
    
    private func showProgressUploadUploadFileLater(_ record: RecordsObj){
        let languageModel = LanguageModel(NSDictionary.init())
        languageModel.code = record.language_code
        let detailVC = ProcessRecordingViewController()
        detailVC.languageModel = languageModel
        detailVC.mergeAudioURL = self.mergeAudioURL
        detailVC.tapComplete = { [] transaction, summary, title, emoji in
            self.naviLabel.text = emoji + " " + title
            self.headerDetailHomeViewController?.skeletonView(isShow: false)
            self.editRecordAudio(transaction, title, emoji)
            self.summaryText = summary ?? ""
            self.transcriptionText = transaction
            self.saveRecordAction(action: .transcription, text: transaction)
            if let actionRecordViewController = self.actionRecordViewController{
                if actionRecordViewController.arrControllerTabs.count > 0 {
                    let vc = actionRecordViewController.arrControllerTabs[0]
                    vc.tabDetailOpenAI.general = transaction
                    vc.tabDetailOpenAI.desc = transaction
                    vc.updateTranscripiton(transaction)
                }
                if let summary = summary{
                    actionRecordViewController.addNewPage(action: .summary, desc: summary)
                }
            }
           
            self.saveRecordAction(action: .summary, text: summary ?? "")
        }
        detailVC.tapCancel = { [] in
            self.headerDetailHomeViewController?.stopPlayer()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        let rowVC: PanModalPresentable.LayoutType = detailVC
        self.presentPanModal(rowVC)
    }
    
    private func showProgressUploadFile(){
        let detailVC = ProcessRecordingViewController()
        detailVC.languageModel = languageModel
        detailVC.mergeAudioURL = self.mergeAudioURL
        detailVC.tapComplete = { [] transaction, summary, title, emoji in
            self.headerDetailHomeViewController?.skeletonView(isShow: false)
            self.naviLabel.text = emoji + " " + title
            self.saveRecordAudio(transaction, title, emoji)
            self.transcriptionText = transaction
            self.summaryText = summary ?? ""
            self.saveRecordAction(action: .transcription, text: transaction)
            if let actionRecordViewController = self.actionRecordViewController{
                if actionRecordViewController.arrControllerTabs.count > 0 {
                    let vc = actionRecordViewController.arrControllerTabs[0]
                    vc.tabDetailOpenAI.general = transaction
                    vc.tabDetailOpenAI.desc = transaction
                    vc.updateTranscripiton(transaction)
                }
                if let summary = summary{
                    actionRecordViewController.addNewPage(action: .summary, desc: summary)
                }
            }
            
            self.saveRecordAction(action: .summary, text: summary ?? "")
        }
        detailVC.tapCancel = { [] in
            self.headerDetailHomeViewController?.stopPlayer()
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
        }
        let rowVC: PanModalPresentable.LayoutType = detailVC
        self.presentPanModal(rowVC)
    }
    
    private func getAllActionRecord(record: RecordsObj){
        let actionRecords = CoreDataManager.shared.fetchRecordActions(recordId: record.id)
        self.actionRecordViewController?.setUpPageMenuAllActionLocals(recordActions: actionRecords)
        if actionRecords.count > 0{
            self.summaryText = actionRecords[1].text
        }
    }
}

extension DetailHomeViewController: UIScrollViewDelegate, TPDataSource, TPProgressDelegate {
    func headerViewController() -> UIViewController {
        let controller = HeaderDetailHomeViewController.instantiate()
        controller.mergeAudioURL = mergeAudioURL
        headerDetailHomeViewController = controller
        return controller
    }
    
    func bottomViewController() -> UIViewController & PagerAwareProtocol {
        let controller = ActionRecordViewController.instantiate()
        controller.detailHomeViewController = self
        controller.recordObj = recordObj
        controller.recordId = recordId
        actionRecordViewController = controller
        return controller
    }
    
    func minHeaderHeight() -> CGFloat {
        return 12
    }
    
    func tp_scrollView(_ scrollView: UIScrollView, didUpdate progress: CGFloat) {
        if scrollView.contentOffset.y > 50 {
            naviLabel.isHidden = false
        }
        else{
            naviLabel.isHidden = true
        }
    }
    
    func tp_scrollViewDidLoad(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
    }
}
