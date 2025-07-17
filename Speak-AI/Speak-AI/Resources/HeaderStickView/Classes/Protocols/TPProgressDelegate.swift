//
//  TPProgressDelegate.swift


import UIKit

public protocol TPProgressDelegate: AnyObject {
    func tp_scrollView(_ scrollView: UIScrollView, didUpdate progress: CGFloat)
    func tp_scrollViewDidLoad(_ scrollView: UIScrollView)
}
