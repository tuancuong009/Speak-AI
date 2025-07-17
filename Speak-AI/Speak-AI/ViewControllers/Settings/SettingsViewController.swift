//
//  SettingsViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit
import MessageUI
import StoreKit
import AVKit
import ApphudSDK
import SafariServices
class SettingsViewController: BaseViewController {

    @IBOutlet weak var lblLanguage: UILabel!
    @IBOutlet weak var lblSize: UILabel!
    private var isDeleteData = false
    @IBOutlet weak var strackPremium: UIStackView!
    @IBOutlet weak var lblUserId: UILabel!
    @IBOutlet weak var lblVersion: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        sizeFile()
        lblUserId.text = "UserId: " +  Apphud.userID()
        lblVersion.text = "Version: \(Bundle.versionApp())"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lblLanguage.text = LanguageAssemblyAI.shared.firstLanguage()?.name
        strackPremium.isHidden = TempStorage.shared.isPremium
    }

    @IBAction func doRestore(_ sender: Any) {
        self.showBusy()
        Apphud.restorePurchases{ subscriptions, purchases, error in
            self.hideBusy()
           if Apphud.hasActiveSubscription(){
               TempStorage.shared.isPremium = true
               self.strackPremium.isHidden = TempStorage.shared.isPremium
               self.showMessageComback("Restore Successfully") { success in
                   
               }
           } else {
               if let error = error{
                   self.showMessageComback(error.localizedDescription) { success in
                       
                   }
               }
               else{
                   self.showMessageComback("Unfortunately, we couldn't find any previous purchases") { success in
                       
                   }
               }
           }
        }
    }
    
   
    
    @IBAction func doPrivacy(_ sender: Any) {
        // MARK: - Open link privacy
        if let url = URL.init(string: ConfigSettings.PRIVACY){
            let vc = WebViewController.init()
            vc.url = url
            self.navigationController?.pushViewController(vc, animated: true)
        }
        // MARK: - Open page
       // let privacyVC = PrivacyPolicyViewController.instantiate()
       // self.navigationController?.pushViewController(privacyVC, animated: true)
    }
    
    @IBAction func doGetPremium(_ sender: Any) {
        let vc = PaywallViewController.instantiate()
        let nav = UINavigationController(rootViewController: vc)
        nav.isNavigationBarHidden = true
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @IBAction func doBack(_ sender: Any) {
        if isDeleteData{
            APP_DELEGATE.initHome()
        }
        else{
            navigationController?.popViewController(animated: true)
        }
        
    }
    
    @IBAction func doReviews(_ sender: Any) {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id\(ConfigSettings.APP_ID)?action=write-review") else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
    
    @IBAction func doSendFeedback(_ sender: Any) {
        self.openComposeEmail(subject: ConfigSettings.TITLE_FEEDBACK, email: ConfigSettings.EMAIL, title: "Write your feedback below 👇 :")
    }
    
    @IBAction func doReportABug(_ sender: Any) {
        self.openComposeEmail(subject: ConfigSettings.TITLE_REPORT_BUG, email: ConfigSettings.EMAIL, title: "Please describe the bug you’re facing 👇 :")
    }
    
    @IBAction func doDeleteNotes(_ sender: Any) {
        let alertVC = UIAlertController.init(title: ConfigSettings.APP_NAME, message: "Are you sure you want to delete all notes and records? This action cannot be undone.", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction.init(title: "No".localized(), style: .cancel) { action in
            
        }
        alertVC.addAction(cancelAction)
        let delete = UIAlertAction.init(title: "Delete".localized(), style: .destructive) { action in
            let records = CoreDataManager.shared.fetchAllRecords()
            for record in records {
                FileManagerHelper.shared.deleteFile(fileName: record.file, folderName: FILE_NAME.records)
            }
            CoreDataManager.shared.deleteAllRecords()
            CoreDataManager.shared.deleteAllRecordActions()
            self.isDeleteData = true
            self.lblSize.text = "0 KB"
        }
        alertVC.addAction(delete)
        self.present(alertVC, animated: true) {
            
        }
    }
    
    @IBAction func doShare(_ sender: Any) {
        self.shareContent(contents: ["📲 Install \(ConfigSettings.APP_NAME) Now: https://apps.apple.com/app/id\(ConfigSettings.APP_ID)"])
    }
    
    @IBAction func doLanguage(_ sender: Any) {
        let nextVC = TranscriptionLanguageViewController.instantiate()
        self.navigationController?.pushViewController(nextVC, animated: true)
    }
}


extension SettingsViewController{
    
    private func sizeFile(){
        var totalSize = 0.0
        let records = CoreDataManager.shared.fetchAllRecords()
        for record in records {
            totalSize = totalSize + record.filesize
        }
        self.lblSize.text = formatBytes(bytes: Int64(totalSize))
    }
    
    private func formatBytes(bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB] // hoặc .useAll nếu muốn đầy đủ
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
    
    private func showRateApp(){
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    func openComposeEmail(subject: String,email: String, title: String) {
        let langCode = Bundle.main.preferredLocalizations[0]
        let usLocale = Locale(identifier: "en-US")
        var langName = ""
        if let languageName = usLocale.localizedString(forLanguageCode: langCode) {
            langName = languageName
        }
        guard MFMailComposeViewController.canSendMail() else { return }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setSubject(subject)
        mail.setToRecipients([email])
        let message =
            """
            <b>\(title)</b><br><br><br><br>
            
            
            
            
            
            
            <b>Diagnostic Information</b>
            <br>App Version: \(Bundle.mainAppVersion ?? "1.0")
            <br>Platform: iOS
            <br>Device: \(UIDevice.current.modelName)
            <br>Language: \(langName)
            <br> User Id: \(Apphud.userID())
            <br>OS Version: \(UIDevice.current.systemVersion)
            """
        mail.setMessageBody(message, isHTML: true)
        present(mail, animated: true)
    }

    // Open App Privacy Settings
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func shareContent(contents: [Any]) {
        let activityVC = UIActivityViewController(activityItems: contents, applicationActivities: nil)
        
        if let popoverController = activityVC.popoverPresentationController {
          popoverController.sourceView = self.view
          popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
          popoverController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async {
            self.present(activityVC, animated: true, completion: nil)
        }
    }
}
// MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
