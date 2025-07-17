//
//  UIWindowExtensions.swift
//

import UIKit

public extension UIWindow {
    static var key: UIWindow? {
        if #available(iOS 13, *) {
            return UIApplication.shared.windows.first { $0.isKeyWindow }
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}

extension NSObject {
    
    class var className: String {
        return "\(self)"
    }
}
