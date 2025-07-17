//
//  UILabelExtensions.swift
//

import UIKit

struct TextAttribute {
    var content: String
    var font: UIFont
    var color: UIColor
}

extension UILabel {
    func showError(_ error: Bool, _ message: String? = nil) {
        self.text = error ? message : nil
    }
    
    func createAttribute(content: String, highlightContent: String, contentFont: UIFont, highlightFont: UIFont, contentColor: UIColor, highlightColor: UIColor) {
        let attribute = NSMutableAttributedString()
        
        let contentAttribute: [NSAttributedString.Key: Any] = [.font: contentFont, .foregroundColor: contentColor]
        let highlightAttribute: [NSAttributedString.Key: Any] = [.font: highlightFont, .foregroundColor: highlightColor]
        
        attribute.append(NSAttributedString(string: content, attributes: contentAttribute))
        attribute.append(NSAttributedString(string: highlightContent, attributes: highlightAttribute))
        
        DispatchQueue.main.async {
            self.attributedText = attribute
        }
    }
    
    func setAttribute(_ attributes: [TextAttribute], highlightText: String? = nil, highlightTextAttribute: [NSAttributedString.Key: Any]) {
        let attributeString = NSMutableAttributedString()
        for textAttribute in attributes {
            let contentAttribute: [NSAttributedString.Key: Any] = [.font: textAttribute.font, .foregroundColor: textAttribute.color]
            attributeString.append(NSAttributedString(string: textAttribute.content, attributes: contentAttribute))
        }
        
        if let highlightText = highlightText {
            attributeString.setHighLightText(textToFind: highlightText, attibs: highlightTextAttribute)
        }
        
        DispatchQueue.main.async {
            self.attributedText = attributeString
        }
    }
    
    func maxNumberOfLines(font: UIFont, string: String) -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(MAXFLOAT))
        let text = string as NSString
        let textHeight = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil).height
        let lineHeight = font.lineHeight
        return Int(ceil(textHeight / lineHeight))
    }
}

extension UILabel {
    func setTextWithSpacing(text: String, lineHeight: CGFloat, letterSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineHeight - self.font.lineHeight
        paragraphStyle.alignment = self.textAlignment

        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttributes([
            .font: self.font as Any, // Đảm bảo font được giữ nguyên
            .paragraphStyle: paragraphStyle,
            .kern: letterSpacing // Letter spacing (tracking)
        ], range: NSRange(location: 0, length: text.count))
        print(attributedString)
        self.attributedText = attributedString
    }
}
extension UILabel {
    func calculateHeightForAttributedText(width: CGFloat) -> CGFloat {
        guard let attributedText = self.attributedText else { return 0 }
        
        let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let rect = attributedText.boundingRect(with: size,
                                               options: [.usesLineFragmentOrigin, .usesFontLeading],
                                               context: nil)
        return ceil(rect.height)
    }
}
