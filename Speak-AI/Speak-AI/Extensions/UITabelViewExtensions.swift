//
//  UITabelViewExtensions.swift
//

import UIKit

extension UITableView {
    func registerNibCell(identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellReuseIdentifier: identifier)
    }
    
    func registerNibCells(identifiers: [String]) {
        for identifier in identifiers {
            self.registerNibCell(identifier: identifier)
        }
    }
    
    func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(
            withIdentifier: T.className,
            for: indexPath
        ) as! T
    }
}

extension UITableViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
