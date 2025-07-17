//
//  BottomPageDelegate.swift


import UIKit

public protocol BottomPageDelegate: AnyObject {
    func tp_pageViewController(_ currentViewController: UIViewController?, didSelectPageAt index: Int)
}
