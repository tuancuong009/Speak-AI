//
//  UIViewExtesion+Helpers.swift
//

import UIKit

extension UIView {
    
    func removeAllSubView() {
        self.subviews.forEach { (sub) in
            sub.removeFromSuperview()
        }
    }
    
    func bringViewToFront() {
        self.superview?.bringSubviewToFront(self)
    }
    
    func sendViewToBack() {
        self.superview?.sendSubviewToBack(self)
    }
    
    func addBorder(borderWidth: CGFloat = 0, borderColor: UIColor = .clear, cornerRadius: CGFloat = 0) {
        self.layer.borderWidth   = borderWidth
        self.layer.borderColor   = borderColor.cgColor
        self.layer.cornerRadius  = cornerRadius
    }
    
    var asUILabel: UILabel? {
        self as? UILabel
    }
    
    var asUIButton: UIButton? {
        self as? UIButton
    }
    
    var asUIImageView: UIImageView? {
        self as? UIImageView
    }
    
    func fixInView(_ container: UIView) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        self.frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func addShadow(color: UIColor, offset: CGSize, radius: CGFloat) {
        self.clipsToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
    }
    
    
}
