//
//  UIFontExtestion+Heplers.swift
//

import UIKit

enum FontName {
    case light
    case regular
    case medium
    case semibold
    case bold
    
    var font: String {
        switch self {
        case .light:
            return "Inter-Light"
        case .regular:
            return "Inter-Regular"
        case .medium:
            return "Inter-Medium"
        case .semibold:
            return "Inter-SemiBold"
        case .bold:
            return "Inter-Bold"
        }
    }
}

extension UIFont {
    
    static func appFontLight(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.light.font, size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }
    
    static func appFontRegular(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.regular.font, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    static func appFontMedium(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.medium.font, size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    static func appFontSemibold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.semibold.font, size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    static func appFontBold(ofSize size: CGFloat) -> UIFont {
        return UIFont(name: FontName.bold.font, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
}
