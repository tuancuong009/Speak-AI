//
//  PagerAwareProtocol.swift


import UIKit

public protocol PagerAwareProtocol: AnyObject {
    var pageDelegate: BottomPageDelegate? {get set}
    var currentViewController: UIViewController? {get}
    var pagerTabHeight: CGFloat? {get}
}
