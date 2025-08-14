//
//  ProcessRecordingViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 5/3/25.
//

import UIKit
import PanModal
import AVFoundation
import Alamofire
extension ProcessRecordingViewController: PanModalPresentable {
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
class ProcessRecordingViewController: BaseViewController {
    var tapComplete:((_ transaction: String,_ summary: String?, _ title: String, _ emoji: String)->())?
    var tapCancel:(()->())?
    @IBOutlet weak var indicatorUploadAudio: UIActivityIndicatorView!
    @IBOutlet weak var indicatorProcessingTranscibe: UIActivityIndicatorView!
    @IBOutlet weak var indicatorGerating: UIActivityIndicatorView!
    @IBOutlet weak var progressGener: UIProgressView!
    @IBOutlet weak var progressUploadAudio: UIProgressView!
    @IBOutlet weak var progressTransaction: UIProgressView!
    @IBOutlet weak var icSuccessTransaction: UIImageView!
    @IBOutlet weak var icSuccessAudio: UIImageView!
    @IBOutlet weak var icSuccessSummary: UIImageView!
    var isCompleteUploadAudio = false
    var isCompleteTransaction = false
    var isCompleteGenre = false
    var languageModel: LanguageModel?
   // var recordings = [URL]()
    var mergeAudioURL: URL?
    
    private var upload_url: String?
    private var transactionText = ""
    private var titleEmoji = ""
    private var emoji = ""
    private var summaryText = ""
    var request: DataRequest?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func doClose(_ sender: Any) {
        request?.cancel()
        dismiss(animated: true) {
            self.tapCancel?()
        }
    }
    
    public func progressFileAudio(_ url: URL){
        self.mergeAudioURL = url
        self.uploadLocalFileAsBinary(fileUrl: url, to: ConfigAssemblyAI.URL + "/v2/upload")
    }
}


extension ProcessRecordingViewController{
    private func setupUI(){
        indicatorUploadAudio.startAnimating()
        indicatorGerating.startAnimating()
        indicatorProcessingTranscibe.startAnimating()
        guard let mergeAudioURL = mergeAudioURL else{
            return
        }
        self.progressFileAudio(mergeAudioURL)
    }
    
   
    
    private func uploadLocalFileAsBinary(fileUrl: URL, to serverUrl: String) {
        do {
            let fileData = try Data(contentsOf: fileUrl)
            
            var request = URLRequest(url: URL(string: serverUrl)!)
            request.httpMethod = "POST"
            request.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
            request.setValue(ConfigAssemblyAI.API, forHTTPHeaderField: "Authorization")
            request.httpBody = fileData
            AF.request(request)
                .uploadProgress { progress in
                    let percentage = Int(progress.fractionCompleted * 100)
                    print("📤 Upload progress: \(percentage)%")
                    self.progressUploadAudio.setProgress(Float(progress.fractionCompleted), animated: true)
                    self.indicatorUploadAudio.isHidden = percentage == 100 ? true : false
                    self.icSuccessAudio.isHidden = percentage == 100 ? false : true
                }
                .validate()
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        if let json = value as? [String: Any] {
                            
                            self.upload_url = json["upload_url"] as? String
                            print("✅ JSON Response: \(self.upload_url ?? "No File")")
                            if let upload_url = self.upload_url{
                                self.requestTranscription(audioUrl: upload_url)
                            }
                        }
                    case .failure(let error):
                        AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: "Upload fail: \(error)", AnalyticsProperty.screen: "Process Recording"])
                        
                        self.showMessageComback("❌ Upload failed: \(error)") { success in
                            
                        }
                        print("❌ Upload failed: \(error)")
                    }
                }
        } catch {
            AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: "Could not read file: \(error.localizedDescription)", AnalyticsProperty.screen: "Process Recording"])
            
            self.showMessageComback("Could not read file: \(error.localizedDescription)") { success in
                
            }
            print("❌ Could not read file: \(error.localizedDescription)")
        }
    }
    
    func requestTranscription(audioUrl: String) {
        let apiKey = ConfigAssemblyAI.API
        let transcriptionUrl = "\(ConfigAssemblyAI.URL)/v2/transcript"
        var parameters:Parameters = [:]
        if let languageModel = languageModel{
            let (isAuto, _) = AppSetings.shared.checkIsAutoLanguage(languageModel.code)
            if isAuto{
                parameters["language_detection"] = true
            }
            else{
                parameters["language_code"] = languageModel.code
                if !languageModel.isBest{
                    parameters["speech_model"] = "nano"
                }
            }
        }
        parameters["audio_url"] = audioUrl
        print("parameters--->",parameters)
        let headers: HTTPHeaders = [
            "Authorization": apiKey,
            "Content-Type": "application/json"
        ]
        
        self.request =  AF.request(transcriptionUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
       
        request?.validate()
            .uploadProgress { progress in
                let percentage = Int(progress.fractionCompleted * 100)
                self.progressTransaction.setProgress(Float(progress.fractionCompleted), animated: true)
                self.indicatorProcessingTranscibe.isHidden = percentage == 100 ? true : false
                self.icSuccessTransaction.isHidden = percentage == 100 ? false : true
                print("📤 checkTranscriptionStatus progress: \(percentage)%")
            }
        
            .responseJSON { response in
//                if let data = response.data {
//                   print("📤 Raw response: \(String(data: data, encoding: .utf8) ?? "N/A")")
//               }
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let transcriptId = json["id"] as? String {
                        print("✅ Success! ID: \(transcriptId)")
                        
                        self.checkTranscriptionStatus(transcriptId: transcriptId)
                    } else {
                        self.showMessageComback("Not get transcript ID") { success in
                            
                        }
                        print("❌ Not get transcript ID")
                    }
                case .failure(let error):
                    self.showMessageComback("❌ Fail: \(error)") { success in
                        
                    }
                    print("❌ Fail: \(error)")
                }
            }
    }
    
    
    func checkTranscriptionStatus(transcriptId: String) {
        let apiKey = ConfigAssemblyAI.API
        let transcriptUrl = "\(ConfigAssemblyAI.URL)/v2/transcript/\(transcriptId)"
        request =   AF.request(transcriptUrl, headers: ["Authorization": apiKey])
        print("transcriptUrl-->",transcriptUrl)
            
        request?.validate()
            .responseJSON { response in
                print("response-->",response)
                switch response.result {
                case .success(let value):
                    if let json = value as? [String: Any], let status = json["status"] as? String {
                        print("📌 status : \(status)")
                        if status == "completed" {
                            if let text = json["text"] as? String {
                                print("✅ Text from audio: \(text)")
                                if text.trimmed.isEmpty{
                                    AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: "Cannot get the transcription", AnalyticsProperty.screen: "Process Recording"])
                                    
                                    self.showMessageComback("Cannot get the transcription, please try again.") { success in
                                        APP_DELEGATE.initHome()
                                    }
                                }
                                else{
                                    self.transactionText = text
                                    
                                    self.getSummary(from: text) { icon, title, summary in
                                        self.summaryText = summary ?? ""
                                        self.titleEmoji = title ?? ""
                                        self.emoji = icon ?? ""
                                        self.dismiss(animated: true) {
                                            self.tapComplete?(self.transactionText, self.summaryText, self.titleEmoji, self.emoji)
                                        }
                                    }
                                }
                            }
                        } else if status == "failed"  || status == "error"{
                            print("❌ Fail")
                            AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: "Cannot get the transcription", AnalyticsProperty.screen: "Process Recording"])
                            self.showMessageComback("Cannot transcribe the audio file, please try again.") { success in
                                APP_DELEGATE.initHome()
                            }
                        } else {
                            print("⏳ Progress")
                            DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                                self.checkTranscriptionStatus(transcriptId: transcriptId)
                            }
                        }
                    }
                case .failure(let error):
                    AnalyticsManager.shared.trackEvent(.Error_Occurred, properties: [AnalyticsProperty.errorType: "Network", AnalyticsProperty.errorMessage: error.localizedDescription, AnalyticsProperty.screen: "Process Recording"])
                    self.showMessageComback("\(error.localizedDescription)") { success in
                        APP_DELEGATE.initHome()
                    }
                    print("❌ Error Status: \(error)")
                }
            }
    }
    
    private func getSummary(from text: String, completion: @escaping (String?, String?, String?) -> Void) {
        self.getEmojiAndIcon(from: text) { icon, title in
            let action: ActionAI = .summary
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(ConfigAOpenAI.Summaries)",
                "Content-Type": "application/json"
            ]
            
            let parameters: [String: Any] = [
                "model": "gpt-4o-mini",
                "messages": [
                    ["role": "system", "content": "You are an expert summarizer."],
                    ["role": "user", "content": action.promptFormat(text: text)]
                ],
                "temperature": 0.5
            ]
            print(parameters)
            AF.request(ConfigAOpenAI.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .validate()
                .downloadProgress { progress in
                    let percentage = Int(progress.fractionCompleted * 100)
                    print("📤 Upload progress: \(percentage)%")
                    self.progressGener.setProgress(Float(progress.fractionCompleted), animated: true)
                    self.indicatorGerating.isHidden = percentage == 100 ? true : false
                    self.icSuccessSummary.isHidden = percentage == 100 ? false : true
                    
                }
                .responseDecodable(of: OpenAIResponse.self) { response in
                    switch response.result {
                    case .success(let openAIResponse):
                        if let summary = openAIResponse.choices.first?.message.content {
                            print("✅ Summary: \(summary)")
                            completion(icon, title,summary)
                        } else {
                            print("❌ No summary found")
                            completion(nil,nil,nil)
                        }
                    case .failure(let error):
                        print("❌ Error: \(error)")
                        completion(nil,nil,nil)
                    }
                }
        }
        
    }
    
    
    private func getEmojiAndIcon(from text: String, completion: @escaping (String?, String?) -> Void) {
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(ConfigAOpenAI.Summaries)",
            "Content-Type": "application/json"
        ]
        
        let parameters: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are an expert summarizer."],
                ["role": "user", "content": "please summary the text to a json data with key \"icon\" for 1 emoji of the text, key \"title\" is the title of the text \"\(text)\""]
            ],
            "temperature": 0.5
        ]
        print(parameters)
        AF.request(ConfigAOpenAI.url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .downloadProgress { progress in
               
                
            }
            .responseDecodable(of: OpenAIResponse.self) { response in
                switch response.result {
                case .success(let openAIResponse):
                    if let summary = openAIResponse.choices.first?.message.content {
                        print("✅ Summary: \(summary)")
                        let cleaned = summary
                            .replacingOccurrences(of: "```json", with: "")
                            .replacingOccurrences(of: "```", with: "")
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if let jsonData = cleaned.data(using: .utf8) {
                            // Bước 3: Decode
                            do {
                                let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
                                if let dict = decoded as? [String: Any] {
                                    print("✅ Parsed JSON:", dict)
                                    completion(dict["icon"] as? String, dict["title"] as? String)
                                }
                            } catch {
                                print("❌ JSON Decode error:", error)
                            }
                        }
                    } else {
                        print("❌ No summary found")
                        completion(nil, nil)
                    }
                case .failure(let error):
                    print("❌ Error: \(error)")
                    completion(nil, nil)
                }
            }
    }
}

/*
 ["role": "user", "content": "please summary the text to a json data with key \"icon\" for 1 emoji of the text, key \"title\" is the title of the text, key \"summary\" is the summary the text, please \"\(action.promptFormat(text: text))\""]
 */

