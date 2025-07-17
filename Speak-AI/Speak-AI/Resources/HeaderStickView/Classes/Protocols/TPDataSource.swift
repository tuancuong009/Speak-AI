//
//  TPDataSource.swift


import UIKit

public protocol TPDataSource: AnyObject {
    func headerViewController() -> UIViewController
    func bottomViewController() -> UIViewController & PagerAwareProtocol
    func minHeaderHeight() -> CGFloat //stop scrolling headerView at this point
}
