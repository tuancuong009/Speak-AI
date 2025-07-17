//
//  StringExtension+Helpers.swift
//


import UIKit
import CryptoKit
import CommonCrypto

extension String {
    
    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var asURL: URL? {
        URL.init(string: self)
    }
    
    var asJSON: [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
    }
    
    var asArray: [Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [Any]
    }
    
    var asAttributedString: NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
    }
    
    var containsOnlyDigits: Bool {
        let notDigits = NSCharacterSet.decimalDigits.inverted
        return rangeOfCharacter(from: notDigits, options: String.CompareOptions.literal, range: nil) == nil
    }
    
    var isAlphanumeric: Bool {
        !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isValidPhone: Bool {
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: self.trimmed)
    }
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailText = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailText.evaluate(with: self.trimmed)
    }
    
    var isValidPassword: Bool {
        /*
         Minimum 8 characters at least 1 Alphabet and 1 Number:
         "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
         ----
         Minimum 8 characters at least 1 Alphabet, 1 Number and 1 Special Character:
         "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
         ----
         Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet and 1 Number:
         "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
         ----
         Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
         let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
         ----
         Minimum 8 and Maximum 10 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character:
         "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,10}"
         */
        
        let passwordRegEx = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        let passwordText = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordText.evaluate(with: self)
    }
    
    var wordCount: Int {
        let regex = try? NSRegularExpression(pattern: "\\w+")
        return regex?.numberOfMatches(in: self, range: NSRange(location: 0, length: self.utf16.count)) ?? 0
    }
    
    var bool: Bool? {
        if self == "0" || self == "false" {
            return false
        }
        if self == "1" || self == "true" {
            return true
        }
        return nil
    }
    
    var int: Int? {
        return Int(self)
    }
    
    func invalidURL() -> String {
        if self.hasPrefix("http") {
            return self
        }
        
        return "https://\(self)"
    }
    
    func withPrefix(_ prefix: String) -> String {
        if self.hasPrefix(prefix) { return self }
        return "\(prefix)\(self)"
    }
    
    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: self.lowercased())
    }
    
    func sha256() -> String {
        let inputData = Data(utf8)
        
        if #available(iOS 13.0, *) {
            let hashed = SHA256.hash(data: inputData)
            return hashed.compactMap { String(format: "%02x", $0) }.joined()
        } else {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            inputData.withUnsafeBytes { bytes in
                _ = CC_SHA256(bytes.baseAddress, UInt32(inputData.count), &digest)
            }
            return digest.makeIterator().compactMap { String(format: "%02x", $0) }.joined()
        }
    }
    
    func timeStampValue() -> String {
        let characters = self[0...9]
        return String(characters)
    }
    
    func ranges(of substring: String, options: CompareOptions = [], locale: Locale? = nil) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        while let range = range(of: substring, options: options, range: (ranges.last?.upperBound ?? self.startIndex)..<self.endIndex, locale: locale) {
            ranges.append(range)
        }
        return ranges
    }
    
    var isTikTokShortLink: Bool {
        if self.lowercased().hasPrefix("https://vm.tiktok.com") || self.lowercased().hasPrefix("https://vt.tiktok.com") || self.lowercased().hasPrefix("https://m.tiktok.com") {
            return true
        }
        return false
    }
    
    var isTikTokFullLink: Bool {
        if self.lowercased().hasPrefix("https://www.tiktok.com") {
            return true
        }
        return false
    }
    
    var isShortLinkValid: Bool {
        guard let url = asURL else {
            return false
        }
        
        let path = url.path.replacingOccurrences(of: "/", with: "")
        if path.isEmpty {
            return false
        }
        return true
    }
    
    func urlSongPathName(songId: String) -> String {
        let newString = self.replacingOccurrences(of: "(", with: "").replacingOccurrences(of: "}", with: "")
        let components = newString.components(separatedBy: " ").filter({$0 != " "})
        var allowName: [String] = []
        for text in components {
            if text.contains("#") {
                continue
            }
            allowName.append(text)
        }
        allowName.append(songId)
        let combineName = allowName.joined(separator: "-")
        return combineName
    }
    
    // MARK: - SUBSCRIPT
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start..<end]
    }
    
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        if end < start { return "" }
        return self[start...end]
    }
    
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex...end]
    }
    
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        if end < startIndex { return "" }
        return self[startIndex..<end]
    }
    
    // MARK: - STRING.WIDTH(…) VÀ STRING.HEIGHT(…)
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

// MARK: - NSATTRIBUTEDSTRING
extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension String {
    
    func toAPIDate(_ format: String = "yyyy-MM-dd HH:mm:ss") -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(secondsFromGMT: 10 * 3600)
        dateFormat.dateFormat = format
        return dateFormat.date(from: self)
    }
    
    func toDate(_ format: String) -> Date? {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.dateFormat = format
        return dateFormat.date(from: self)
    }
    
    func convertToReleaseDate() -> String {
        let dateFormat = DateFormatter()
        dateFormat.timeZone = TimeZone(abbreviation: "UTC")
        dateFormat.dateFormat = "yyyy-MM-dd"
        let date = dateFormat.date(from: self)
        
        if let date = date {
            dateFormat.dateFormat = "MMM d, yyyy"
            return dateFormat.string(from: date)
        }
        
        return self
    }
}

extension NSMutableAttributedString {
    func setAsLink(textToFind: String, linkName: String) {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.link, value: linkName, range: foundRange)
        }
    }
    
    func setHighLightText(textToFind: String, attibs: [NSAttributedString.Key : Any]) {
        let foundRange = self.mutableString.range(of: textToFind)
        let lowerFoundRange = self.mutableString.range(of: textToFind.lowercased())
        let upperFoundRange = self.mutableString.range(of: textToFind.uppercased())
        let capitalizedFoundRange = self.mutableString.range(of: textToFind.capitalized)
        if foundRange.location != NSNotFound {
            self.addAttributes(attibs, range: foundRange)
        } else if lowerFoundRange.location != NSNotFound {
            self.addAttributes(attibs, range: lowerFoundRange)
        } else if upperFoundRange.location != NSNotFound {
            self.addAttributes(attibs, range: upperFoundRange)
        } else if capitalizedFoundRange.location != NSNotFound {
            self.addAttributes(attibs, range: capitalizedFoundRange)
        }
    }
}

extension String {
    
    func isValidDouble(maxDecimalPlaces: Int) -> Bool {
        let formatter = NumberFormatter()
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."
        
        if let _ = formatter.number(from: self) {
            let split = self.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            
            return digits.count <= maxDecimalPlaces
        }
        
        return false
    }
}
