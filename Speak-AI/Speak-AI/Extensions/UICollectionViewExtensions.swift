//
//  UICollectionViewExtensions.swift
//


import UIKit

extension UICollectionView {
    
    func registerNibCell(identifier: String) {
        self.register(UINib(nibName: identifier, bundle: nil), forCellWithReuseIdentifier: identifier)
    }
    
    func scrollToIndex(_ indexPath: IndexPath, animation: Bool) {
        self.isPagingEnabled = false
        self.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: animation)
        self.isPagingEnabled = true
    }
    
    func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.className, for: indexPath) as! T
    }
    
    func dequeueReusableView<T: UICollectionReusableView>(for indexPath: IndexPath, with kind: String) -> T {
        return dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.className, for: indexPath) as! T
    }
}

extension UICollectionViewCell {
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
}
