//
//  AboutUsViewController.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var lblDesc: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDesc.attributedText = formattedText()
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
    @IBAction func doBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func formattedText() -> NSAttributedString {
        let fullText = """
    At SpeakAI, we believe your voice holds value so we built a powerful tool to help you turn spoken thoughts into organized, actionable notes.

    Whether you're recording meetings, lectures, interviews, or personal reflections, SpeakAI makes it effortless to transcribe, summarize, translate, and organize your audio and video files with the help of AI. Everything happens locally on your device, giving you full privacy and control over your data.

    We designed SpeakAI for creators, students, professionals, and thinkers—anyone who wants to capture ideas and make the most of them.

    Speak smarter. Work faster. Keep your voice in your hands.
    """

        let boldPhrases = [
            "SpeakAI,",
            "transcribe, summarize, translate, and organize",
            "locally on your device",
            "Speak smarter. Work faster. Keep your voice in your hands."
        ]
        
        let attributed = NSMutableAttributedString(string: fullText)
        let fullRange = NSRange(location: 0, length: attributed.length)
        
        // Set base font
        let baseFont = UIFont.appFontRegular(ofSize: 14)
        attributed.addAttribute(.font, value: baseFont, range: fullRange)
        
        // Apply bold to specific phrases
        let boldFont = UIFont.appFontBold(ofSize: 14)
        for phrase in boldPhrases {
            let ranges = rangesOfSubstring(phrase, in: fullText)
            for range in ranges {
                attributed.addAttribute(.font, value: boldFont, range: range)
            }
        }

        return attributed
    }

    // Helper to find all ranges of substring in a string
    func rangesOfSubstring(_ substring: String, in text: String) -> [NSRange] {
        var ranges: [NSRange] = []
        let pattern = NSRegularExpression.escapedPattern(for: substring)
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
            ranges = matches.map { $0.range }
        }
        return ranges
    }
}
