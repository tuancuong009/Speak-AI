//
//  PannableViewsProtocol.swift


import UIKit

public protocol PannableViewsProtocol {
    func panView() -> UIView
}

extension UIViewController: PannableViewsProtocol {
    @objc open func panView() -> UIView {
        if let scroll = self.view.subviews.first(where: {$0 is UIScrollView}) {
            return scroll
        } else {
            return self.view
        }
    }
}
