//
//  HomeViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 6/2/25.
//

import UIKit
import UniformTypeIdentifiers
import PanModal
import SkeletonView
import Alamofire
import AVFoundation
import Mixpanel
import ApphudSDK
class HomeViewController: BaseViewController {
    
    @IBOutlet weak var txfSearch: UITextField!
    @IBOutlet weak var btnPremium: UIButton!
    @IBOutlet weak var cltMenu: UICollectionView!
    @IBOutlet weak var viewContextMenu: UIView!
    @IBOutlet weak var viewMenuContext: UIView!
    @IBOutlet weak var containView: UIView!
    private var folders = [FolderObj]()
    private var folderFirts: FolderObj?
    var pageMenu: CAPSPageMenu?
    var controllers: [UIViewController] = []
    @IBOutlet weak var viewEmpty: UIView!
    @IBOutlet weak var viewSearch: UIView!
    private var indexMenu = 0
    private var typeCreateNote: createNoteType = .uploadAudio
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        APP_DELEGATE.detailHomeViewController = nil
        btnPremium.isHidden = TempStorage.shared.isPremium
    }
    @IBAction func doCreateNote(_ sender: Any) {
        let vc = CreateNoteViewController.instantiate()
        vc.delegate = self
        let rowVC: PanModalPresentable.LayoutType = vc
        presentPanModal(rowVC)
    }
    @IBAction func doRecordAuido(_ sender: Any) {
        permisonAudio()
        
    }
    
    @IBAction func tapContext(_ sender: Any) {
        self.showContextMenu(isShow: false)
    }
    
    
    @IBAction func doPremium(_ sender: Any) {
        AnalyticsManager.shared.trackEvent(.Paywall_Viewed, properties: [AnalyticsProperty.source: "Get Pro CTA"])
        let vc = PaywallViewController.instantiate()
        vc.typePaywall = .getPro
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
        
    }
    
    @IBAction func doEditFolder(_ sender: Any) {
        self.showContextMenu(isShow: false)
        let vc = FolderViewController.instantiate()
        vc.folders = folders
        vc.folderFirts = folderFirts
        vc.tapEditFolder = { [] results in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.folders.removeAll()
                if let first = self.folderFirts{
                    self.folders.append(first)
                }
                self.folders.append(contentsOf: results)
                self.cltMenu.reloadData()
                self.showHideUI()
            }
            
        }
        vc.tapDeleteFolder = { [] results in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.folders.removeAll()
                if let first = self.folderFirts{
                    self.folders.append(first)
                }
                self.folders.append(contentsOf: results)
                self.cltMenu.reloadData()
                self.showHideUI()
                self.pageMenu?.moveToPage(0)
            }
            
        }
        vc.tapAddfolder = { [] value in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.cltMenu.reloadData()
                self.addNewPage(value)
                self.showHideUI()
            }
            self.folders.append(value)
           
           
        }
        vc.tapReoders =  { [] results in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                var updatedFolders: [FolderObj] = []

               if let first = self.folderFirts {
                   updatedFolders.append(first)
               }
               updatedFolders.append(contentsOf: results)

               self.folders = updatedFolders
               self.cltMenu.reloadData()
               self.reloadPageMenuWithNewFolders(updatedFolders)
            }
            
        }
        let rowVC: PanModalPresentable.LayoutType = vc
        presentPanModal(rowVC)
       // present(vc, animated: true)
    }
    
    private func showHideUI(){
        if folders.count == 1 && CoreDataManager.shared.fetchAllRecordsGroupedByHumanReadableDate(searchText: nil).count == 0{
            viewEmpty.isHidden = false
            viewSearch.isHidden = true
            cltMenu.isHidden = true
            containView.isHidden = true
        }
        else{
            viewEmpty.isHidden = true
            viewSearch.isHidden = false
            cltMenu.isHidden = false
            containView.isHidden = false
        }
    }
    
    
    private func updateMixPanel(){
        let folders =  CoreDataManager.shared.fecthAllFolders()
        let records = CoreDataManager.shared.fetchAllRecordsGroupedByHumanReadableDate(searchText: nil)
        let actions = CoreDataManager.shared.fetchAllRecordActions()
        if InApPurchaseManager.shared.isPremiumActive{
            let userProps: Properties = [
                AnalyticsUserProperty.userId: Apphud.userID(),
                AnalyticsUserProperty.appVersion: Bundle.mainAppVersion ?? "1.0",
                AnalyticsUserProperty.osVersion: UIDevice.current.systemVersion,
                AnalyticsUserProperty.deviceModel: UIDevice().modelName,
                AnalyticsUserProperty.subscriptionStatus: InApPurchaseManager.shared.currentPlanType?.type.rawValue ?? "Free",
                AnalyticsUserProperty.subscriptionStartDate: InApPurchaseManager.shared.startDate,
                AnalyticsUserProperty.subscriptionEndDate: InApPurchaseManager.shared.expiresDate,
                AnalyticsUserProperty.totalRecordings: actions.count,
                AnalyticsUserProperty.totalTranscriptions: records.count,
                AnalyticsUserProperty.foldersCreated: folders.count,
                AnalyticsUserProperty.lastActiveDate:  AppOpenTracker.shared.formatDateSubs(date: Date()),
                AnalyticsUserProperty.firstAppOpenDate:  AppOpenTracker.shared.getFirstAppOpenDate() ?? "",
                AnalyticsUserProperty.hasCompletedOnboarding: true,
                AnalyticsUserProperty.languagePreference: LanguageAssemblyAI.shared.firstLanguage()?.name ?? "English"
            ]

            AnalyticsManager.shared.identifyUser(id: userProps[AnalyticsUserProperty.userId] as! String)
            AnalyticsManager.shared.setUserProperties(userProps)
        }
        else{
            let userProps: Properties = [
                AnalyticsUserProperty.userId: Apphud.userID(),
                AnalyticsUserProperty.appVersion: Bundle.mainAppVersion ?? "1.0",
                AnalyticsUserProperty.osVersion: UIDevice.current.systemVersion,
                AnalyticsUserProperty.deviceModel: UIDevice().modelName,
                AnalyticsUserProperty.subscriptionStatus: "Free",
                AnalyticsUserProperty.totalRecordings: actions.count,
                AnalyticsUserProperty.totalTranscriptions: records.count,
                AnalyticsUserProperty.foldersCreated: folders.count,
                AnalyticsUserProperty.lastActiveDate: AppOpenTracker.shared.formatDateSubs(date: Date()),
                AnalyticsUserProperty.firstAppOpenDate:  AppOpenTracker.shared.getFirstAppOpenDate() ?? "",
                AnalyticsUserProperty.hasCompletedOnboarding: true,
                AnalyticsUserProperty.languagePreference: LanguageAssemblyAI.shared.firstLanguage()?.name ?? "English"
            ]

            AnalyticsManager.shared.identifyUser(id: userProps[AnalyticsUserProperty.userId] as! String)
            AnalyticsManager.shared.setUserProperties(userProps)
        }
        
    }
   
    
    
}
extension HomeViewController: CreateNoteViewControllerDelegate{
    func didActionCreateNew(createNoteEnum: createNoteType) {
        typeCreateNote = createNoteEnum
        switch createNoteEnum {
        case .recordAudio:
            AnalyticsManager.shared.trackEvent(.Create_Note_Record_Audio)
            self.permisonAudio()
            break
        case .uploadAudio:
            AnalyticsManager.shared.trackEvent(.Create_Note_Upload_Audio)
            showDocumentPicker(type: .uploadAudio)
        case .uploadVideo:
            AnalyticsManager.shared.trackEvent(.Create_Note_Upload_Video)
            showDocumentPicker(type: .uploadVideo)
        case .useYoutubeLink:
            let nextVC  = YouTubeViewController()
            self.present(nextVC, animated: true)
        }
    }
}
extension HomeViewController : UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
extension HomeViewController{
    func showDocumentPicker(type: createNoteType) {
        if type == .uploadAudio{
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [
                .audio
            ])
            
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        }
        else{
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [
                .movie
            ])
            
            documentPicker.delegate = self
            present(documentPicker, animated: true, completion: nil)
        }
       
    }
    
    private func setupUI(){
        folders = CoreDataManager.shared.fecthAllFolders()
        if folders.count > 0{
            folderFirts = folders[0]
            TempStorage.shared.folderObj = folderFirts
        }
        showHideUI()
        cltMenu.reloadData()
        cltMenu.showsVerticalScrollIndicator = false
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        cltMenu.addGestureRecognizer(longPress)
        self.showContextMenu(isShow: false)
        registerNotification()
        setUpPageMenu()
        if AppDelegate.shared.isOpenRecording{
            AppDelegate.shared.isOpenRecording = false
            permisonAudio()
        }
        if !TempStorage.shared.isCheckInApp{
            TempStorage.shared.isCheckInApp = true
            if !InApPurchaseManager.shared.isPremiumActive{
                AnalyticsManager.shared.trackEvent(.Paywall_Viewed, properties: [AnalyticsProperty.source: "Onboarding"])
                let vc = PaywallViewController.instantiate()
                vc.typePaywall = .onboarding
                let nav = UINavigationController(rootViewController: vc)
                nav.isNavigationBarHidden = true
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
               
            }
        }
        updateMixPanel()
    }
    
    private func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(addNewFoderNotification( _:)), name: NSNotification.Name(rawValue: KeyDefaults.newFolder), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(paywallSuccess), name: NSNotification.Name(rawValue: KEY_NOTIFICATION_NAME.PAYWALL_SUCCESS), object: nil)
    }
    
    @objc func paywallSuccess(){
        updateMixPanel()
    }
    @objc func addNewFoderNotification(_ notification: NSNotification){
        if let object = notification.object as? FolderObj{
            folders.append(object)
            cltMenu.reloadData()
            addNewPage(object)
            showHideUI()
        }
    }
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
       
        if gesture.state == .began {
            impactHaptic(style: .light)
            self.showContextMenu(isShow: true)
        }
    }
    
    private func showContextMenu(isShow: Bool){
        if isShow{
            UIView.animate(withDuration: 0.25) {
                self.viewContextMenu.alpha = 1.0
                self.viewMenuContext.alpha = 1.0
                self.cltMenu.isScrollEnabled = false
            }
        }
        else{
            UIView.animate(withDuration: 0.25) {
                self.viewContextMenu.alpha = 0.0
                self.viewMenuContext.alpha = 0.0
                self.cltMenu.isScrollEnabled = true
            }
        }
    }
    
    func reloadPageMenuWithNewFolders(_ newFolders: [FolderObj]) {
        self.folders = newFolders
            
        // Remove old page menu
        pageMenu?.view.removeFromSuperview()
        pageMenu?.removeFromParent()
        pageMenu = nil
        controllers.removeAll()
        
        containView.layoutIfNeeded()
        
        // Re-setup
        setUpPageMenu()
    }
    
    private func setUpPageMenu()
    {
        for folder in folders{
            let vc  = HomeItemViewController()
            vc.tapHideKeyboard = { [] in
                self.txfSearch.resignFirstResponder()
            }
            vc.folderModel = folder
            vc.homeVC = self
            controllers.append(vc)
        }
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        self.pageMenu = CAPSPageMenu(viewControllers: controllers, frame: CGRect(x: 0, y: 0, width: containView.frame.size.width, height: containView.frame.size.height), pageMenuOptions: parameters)
        
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = true
        containView.addSubview(pageMenu!.view)
    }
    
    func addNewPage(_ folder: FolderObj) {
        let vc  = HomeItemViewController()
        vc.tapHideKeyboard = { [] in
            self.txfSearch.resignFirstResponder()
        }
        vc.folderModel = folder
        vc.homeVC = self
        // Cập nhật danh sách controllers
        controllers.append(vc)

        // Xóa pageMenu hiện tại
        pageMenu?.view.removeFromSuperview()

        // Khởi tạo lại PageMenu với danh sách mới
        let parameters: [CAPSPageMenuOption] = [
            .menuMargin(0),
            .menuItemSeparatorPercentageHeight(0.0),
            .menuHeight(0),
            .titleTextSizeBasedOnMenuItemWidth(true),
        ]
        pageMenu = CAPSPageMenu(viewControllers: controllers, frame: CGRect(x: 0, y: 0, width: containView.frame.size.width, height: containView.frame.size.height), pageMenuOptions: parameters)

        // Thêm vào View
        pageMenu!.delegate = self
        pageMenu?.controllerScrollView.isScrollEnabled = true
        containView.addSubview(pageMenu!.view)
    }
    
    private func permisonAudio(){
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                OperationQueue.main.addOperation() {
                    AnalyticsManager.shared.trackEvent(.Recording_Started, properties: [AnalyticsProperty.recording: "In-App-Recording"])
                    let vc = RecordingViewController.instantiate()
                    vc.tapAgainData = { [] in
                        self.showHideUI()
                        
                    }
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showOpenSettings("The app needs access microphone to record the voice audio, please accept the permission") { success in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
            }
        }
    }
}

extension HomeViewController: CAPSPageMenuDelegate{
    func willMoveToPage(_ controller: UIViewController, index: Int) {
        indexMenu = index
        cltMenu.reloadData()
        cltMenu.scrollToItem(at: IndexPath(row: indexMenu, section: 0), at: .centeredHorizontally, animated: true)
        TempStorage.shared.folderObj = folders[indexMenu]
    }
    
    func didMoveToPage(_ controller: UIViewController, index: Int) {
        
    }
}
extension HomeViewController: UIDocumentPickerDelegate{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Handle picked audio file
        if let selectedFileURL = urls.first {
            print("Picked audio file: \(selectedFileURL.lastPathComponent)")
            if selectedFileURL.startAccessingSecurityScopedResource() {
                if typeCreateNote == .uploadAudio{
                    if !TempStorage.shared.isPremium{
                        let numerLimit = Double(2 * 60)
                        if self.getAudioDuration(from: selectedFileURL) > numerLimit{
                            self.doPremium(Any.self)
                            return
                        }
                    }else{
                        let numerLimit = Double(120 * 60)
                        if self.getAudioDuration(from: selectedFileURL) > numerLimit{
                            self.doPremium(Any.self)
                            return
                        }
                    }
                    
                    let nextVC = UploadRecordingViewController.init()
                    nextVC.mergeAudioURL = selectedFileURL
                    nextVC.tapSaveLater = { [] in
                        
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
                else if typeCreateNote == .uploadVideo{
                    extractAudioFromVideo(videoURL: selectedFileURL)
                }
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
    func getAudioDuration(from url: URL) -> Double {
        let asset = AVAsset(url: url)
        let duration = asset.duration
        let durationInSeconds = CMTimeGetSeconds(duration)

        print("Audio Duration: \(durationInSeconds) seconds")
        return durationInSeconds
    }
    func extractAudioFromVideo(videoURL: URL){
        self.showBusy()
        let asset = AVAsset(url: videoURL)
        let outputFileName = "ExtractedAudio.m4a"
        let outputFilePath = FileManager.default.temporaryDirectory.appendingPathComponent(outputFileName)

        // Remove existing file if exists
        if FileManager.default.fileExists(atPath: outputFilePath.path) {
            try? FileManager.default.removeItem(at: outputFilePath)
        }

        // Configure audio export
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            print("Error: Could not create export session")
            self.hideBusy()
            return
        }

        exportSession.outputURL = outputFilePath
        exportSession.outputFileType = .m4a
        exportSession.exportAsynchronously {
            if exportSession.status == .completed {
                print("Audio extracted successfully: \(outputFilePath)")
                
                DispatchQueue.main.async {
                    self.hideBusy()
                    if !TempStorage.shared.isPremium{
                        let numerLimit = Double(2 * 60)
                        if self.getAudioDuration(from: outputFilePath) > numerLimit{
                            self.doPremium(Any.self)
                            return
                        }
                    }else{
                        let numerLimit = Double(120 * 60)
                        if self.getAudioDuration(from: outputFilePath) > numerLimit{
                            self.doPremium(Any.self)
                            return
                        }
                    }
                    
                    let nextVC = UploadRecordingViewController.init()
                    nextVC.mergeAudioURL = outputFilePath
                    nextVC.tapSaveLater = { [] in
                        
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
                    self.presentPanModal(rowVC)
                }
            } else {
                self.hideBusy()
                print("Error extracting audio: \(exportSession.error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
}

extension HomeViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}
extension HomeViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txfSearch.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            print("Current text: \(updatedText)")
            if let vc = controllers[indexMenu] as? HomeItemViewController, vc.isSetUp{
                vc.getData(updatedText.trimmed)
            }
            NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.SEARCH_HOME), object: updatedText)
        }
            
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let vc = controllers[indexMenu] as? HomeItemViewController, vc.isSetUp{
            vc.getData(nil)
        }
        NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.SEARCH_HOME), object: nil)
        return true
    }
}
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return folders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = cltMenu.dequeueReusableCell(withReuseIdentifier: "MenuHomeCollect", for: indexPath) as! MenuHomeCollect
        cell.lblname.text = folders[indexPath.row].name
        cell.viewSelect.isHidden = indexPath.row == indexMenu ? false : true
        cell.lblname.font = UIFont(name: indexPath.row == indexMenu ? "Inter-SemiBold" : "Inter-Regular", size: 14.0)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        indexMenu = indexPath.row
        cltMenu.reloadData()
        cltMenu.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        pageMenu?.moveToPage(indexMenu)
        TempStorage.shared.folderObj = folders[indexMenu]
    }
}


