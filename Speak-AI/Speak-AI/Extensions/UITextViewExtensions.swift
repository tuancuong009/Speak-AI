//
//  UITextViewExtensions.swift
//

import UIKit

typealias ChangeTextAttributes = (changeText: String, font: UIFont?, foregroundColor: UIColor?)
typealias TextAttributes = [NSAttributedString.Key : Any]?

extension NSAttributedString {
    
    static func create(forTitle title: String, stringsToChange: [ChangeTextAttributes], attributes: TextAttributes = nil) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: title, attributes: attributes)
        stringsToChange.forEach {
            if let index = title.range(of: $0.changeText)?.lowerBound {
                var attributes: [NSAttributedString.Key: Any] = [:]
                attributes[.font] = $0.font
                attributes[.foregroundColor] = $0.foregroundColor
                attributedString.addAttributes(attributes, range: NSRange(location: index.utf16Offset(in: title), length: $0.changeText.count))
            }
        }
        return NSAttributedString(attributedString: attributedString)
    }
    
    static func setAsLink(forAttributedString attributedString: NSMutableAttributedString, value: String, range: String) {
        return attributedString.addAttribute(NSAttributedString.Key.link, value: value, range: attributedString.mutableString.range(of: range))
    }
    
    static func setAsHighlight(forAttributedString attributedString: NSMutableAttributedString, font: UIFont, range: String) {
        return attributedString.addAttribute(.font, value: font, range: attributedString.mutableString.range(of: range))
        
    }
}

public extension NSRange {
    
    private init(string: String, lowerBound: String.Index, upperBound: String.Index) {
        let utf16 = string.utf16

        let lowerBound = lowerBound.samePosition(in: utf16)
        let location = utf16.distance(from: utf16.startIndex, to: lowerBound!)
        let length = utf16.distance(from: lowerBound!, to: upperBound.samePosition(in: utf16)!)

        self.init(location: location, length: length)
    }

    init(range: Range<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }

    init(range: ClosedRange<String.Index>, in string: String) {
        self.init(string: string, lowerBound: range.lowerBound, upperBound: range.upperBound)
    }
}
