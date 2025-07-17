//
//  TranscripitonViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 6/3/25.
//

import UIKit
import MarkdownView
class TranscripitonViewController: BaseViewController {
    var updateTranscriptionDelegate:((_ value: String)->())?
    var tabDetailOpenAI: tabDetailOpenAI = .init()
    @IBOutlet weak var btnRevert: UIButton!
    var detailHomeViewController: DetailRecordingViewController?
    var recordId: String = ""
    var action: ActionAI = .transcription
    @IBOutlet weak var viewAction: UIView!
    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var lblDesc: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTranscripiton(tabDetailOpenAI.desc.trimmed)
       
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

    public func updateTranscripiton(_ text: String){
        print(text)
        lblDesc.attributedText = self.formatText(text.trimmed)
        viewAction.isHidden = false
        btnRevert.isHidden = true
        lblDesc.isHidden = false
        
//        if let detailHomeViewController = detailHomeViewController
//        {
//            detailHomeViewController.updateHeightPageMenu()
//        }
    }
    
    func formatText(_ text: String) -> NSAttributedString {
        let attributed = NSMutableAttributedString()
        let lines = text.components(separatedBy: .newlines)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Title level 1
            if trimmed.hasPrefix("# ") {
                let title = trimmed.replacingOccurrences(of: "# ", with: "")
                attributed.append(NSAttributedString(
                    string: title + "\n",
                    attributes: [
                        .font: UIFont.appFontBold(ofSize: 20),
                        .paragraphStyle: paragraphStyle
                    ]
                ))
                continue
            }

            // Title level 2
            if trimmed.hasPrefix("## ") {
                let subtitle = trimmed.replacingOccurrences(of: "## ", with: "")
                attributed.append(NSAttributedString(
                    string: subtitle + "\n",
                    attributes: [
                        .font: UIFont.appFontBold(ofSize: 18),
                        .paragraphStyle: paragraphStyle
                    ]
                ))
                continue
            }

//            // Title level 3
//            if trimmed.hasPrefix("### ") {
//                let subtitle = trimmed.replacingOccurrences(of: "### ", with: "")
//                attributed.append(NSAttributedString(
//                    string: subtitle + "\n",
//                    attributes: [
//                        .font: UIFont.appFontBold(ofSize: 16),
//                        .paragraphStyle: paragraphStyle
//                    ]
//                ))
//                continue
//            }
            // Title level 3
            if trimmed.hasPrefix("### ") {
                let subtitle = trimmed.replacingOccurrences(of: "### ", with: "")
                let processed = processBoldInline(subtitle, fontSize: 16, isBold: true, paragraphStyle: paragraphStyle)
                attributed.append(processed)
                continue
            }
            // Special case: full line is wrapped in **
            if trimmed.hasPrefix("**") && trimmed.hasSuffix("**") && trimmed.count > 4 {
                let content = trimmed
                    .replacingOccurrences(of: "**", with: "")
                    .trimmingCharacters(in: .whitespaces)

                attributed.append(NSAttributedString(
                    string: content + "\n",
                    attributes: [
                        .font: UIFont.appFontBold(ofSize: 16),
                        .paragraphStyle: paragraphStyle
                    ]
                ))
                continue
            }

            // Handle inline bold text using **
            let pattern = "\\*\\*(.*?)\\*\\*"
            let regex = try? NSRegularExpression(pattern: pattern)
            let nsLine = trimmed as NSString
            var lastIndex = 0
            let matches = regex?.matches(in: trimmed, options: [], range: NSRange(location: 0, length: nsLine.length)) ?? []

            if matches.isEmpty {
                attributed.append(NSAttributedString(
                    string: trimmed + "\n",
                    attributes: [
                        .font: UIFont.appFontRegular(ofSize: 14),
                        .paragraphStyle: paragraphStyle
                    ]
                ))
            } else {
                for match in matches {
                    let boldRange = match.range(at: 1)
                    let fullRange = match.range(at: 0)

                    // Trước bold
                    if fullRange.location > lastIndex {
                        let before = nsLine.substring(with: NSRange(location: lastIndex, length: fullRange.location - lastIndex))
                        attributed.append(NSAttributedString(
                            string: before,
                            attributes: [
                                .font: UIFont.appFontRegular(ofSize: 14),
                                .paragraphStyle: paragraphStyle
                            ]
                        ))
                    }

                    // Bold text
                    let boldText = nsLine.substring(with: boldRange)
                    attributed.append(NSAttributedString(
                        string: boldText,
                        attributes: [
                            .font: UIFont.appFontBold(ofSize: 14),
                            .paragraphStyle: paragraphStyle
                        ]
                    ))

                    lastIndex = fullRange.location + fullRange.length
                }

                // Sau cùng
                if lastIndex < nsLine.length {
                    let remaining = nsLine.substring(from: lastIndex)
                    attributed.append(NSAttributedString(
                        string: remaining,
                        attributes: [
                            .font: UIFont.appFontRegular(ofSize: 14),
                            .paragraphStyle: paragraphStyle
                        ]
                    ))
                }

                attributed.append(NSAttributedString(string: "\n"))
            }
        }

        return attributed
    }

    func processBoldInline(_ text: String, fontSize: CGFloat, isBold: Bool, paragraphStyle: NSParagraphStyle) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let pattern = "\\*\\*(.*?)\\*\\*"
        let regex = try? NSRegularExpression(pattern: pattern)
        let nsText = text as NSString
        var lastIndex = 0
        let matches = regex?.matches(in: text, options: [], range: NSRange(location: 0, length: nsText.length)) ?? []

        if matches.isEmpty {
            result.append(NSAttributedString(string: text + "\n", attributes: [
                .font: isBold ? UIFont.appFontBold(ofSize: fontSize) : UIFont.appFontRegular(ofSize: fontSize),
                .paragraphStyle: paragraphStyle
            ]))
        } else {
            for match in matches {
                let boldRange = match.range(at: 1)
                let fullRange = match.range(at: 0)

                if fullRange.location > lastIndex {
                    let before = nsText.substring(with: NSRange(location: lastIndex, length: fullRange.location - lastIndex))
                    result.append(NSAttributedString(string: before, attributes: [
                        .font: isBold ? UIFont.appFontBold(ofSize: fontSize) : UIFont.appFontRegular(ofSize: fontSize),
                        .paragraphStyle: paragraphStyle
                    ]))
                }

                let boldText = nsText.substring(with: boldRange)
                result.append(NSAttributedString(string: boldText, attributes: [
                    .font: UIFont.appFontBold(ofSize: fontSize),
                    .paragraphStyle: paragraphStyle
                ]))

                lastIndex = fullRange.location + fullRange.length
            }

            if lastIndex < nsText.length {
                let remaining = nsText.substring(from: lastIndex)
                result.append(NSAttributedString(string: remaining, attributes: [
                    .font: isBold ? UIFont.appFontBold(ofSize: fontSize) : UIFont.appFontRegular(ofSize: fontSize),
                    .paragraphStyle: paragraphStyle
                ]))
            }

            result.append(NSAttributedString(string: "\n"))
        }

        return result
    }

    
    @IBAction func doCopy(_ sender: Any) {
        UIPasteboard.general.string = lblDesc.text!.trimmed
        self.showMessageComback("Coppied") { success in
            
        }
    }
    
    @IBAction func doEdit(_ sender: Any) {
        let vc = EditTextViewController.init()
        vc.delegate = self
        vc.text = lblDesc.text!.trimmed
        if self.detailHomeViewController == nil{
            
            APP_DELEGATE.detailHomeViewController?.present(vc, animated: true) {
            }
        }
        else{
            self.detailHomeViewController?.present(vc, animated: true) {
            }
        }
       
    }
    
    @IBAction func doShare(_ sender: Any) {
        let text = lblDesc.text!.trimmed
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        self.present(activityViewController, animated: true, completion: nil)
    }
    @IBAction func doRevert(_ sender: Any) {
        lblDesc.attributedText = self.formatText(tabDetailOpenAI.general.trimmed)
        btnRevert.isHidden = true
        if tabDetailOpenAI.action == .transcription{
            print("tabDetailOpenAI.action--->",tabDetailOpenAI.action)
            _ = CoreDataManager.shared.updateTranscriptionRecord(transcription: tabDetailOpenAI.general, recordId: detailHomeViewController?.recordId ?? "")
            self.updateTranscriptionDelegate?(tabDetailOpenAI.general)
        }
        _ = CoreDataManager.shared.updatTextRecordAction(withID: detailHomeViewController?.recordId ?? "", action: action.rawValue, text: tabDetailOpenAI.general)
        NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.EDIT_TEXT), object: nil)
    }
}

extension TranscripitonViewController: EditTextViewControllerDelegate{
    func savedText(_ text: String) {
        print("text--->",text)
        if tabDetailOpenAI.action == .transcription{
            print("tabDetailOpenAI.action--->",tabDetailOpenAI.action)
            _ = CoreDataManager.shared.updateTranscriptionRecord(transcription: text, recordId: detailHomeViewController?.recordId ?? "")
            self.updateTranscriptionDelegate?(text)
        }
        tabDetailOpenAI.desc = text
        lblDesc.attributedText = self.formatText(text.trimmed)
        btnRevert.isHidden = false
        _ = CoreDataManager.shared.updatTextRecordAction(withID: detailHomeViewController?.recordId ?? "", action: tabDetailOpenAI.action.rawValue, text: text)
        NotificationCenter.default.post(name: NSNotification.Name(NotificationDefineName.EDIT_TEXT), object: nil)
    }
}


extension TranscripitonViewController: UIScrollViewDelegate{
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if let detailHomeViewController = APP_DELEGATE.detailHomeViewController{
//            if detailHomeViewController.naviLabel.isHidden{
//                spaceBottom.constant = 350
//            }
//            else{
//                spaceBottom.constant = 150
//            }
//        }
    }
}
extension Character {
    var isEmoji: Bool {
        unicodeScalars.contains { $0.properties.isEmoji }
    }
}
