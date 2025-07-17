//
//  UIViewExtension.swift

import Foundation
import UIKit

extension UIView{
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    func makeRoundViewCorner( radius : CGFloat)
    {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
}
extension UIView {
    func applyFullShadow(color: UIColor = UIColor.black.withAlphaComponent(0.2),
                             opacity: Float = 0.2,
                             radius: CGFloat = 10,
                             spread: CGFloat = 5) {
            
            self.layer.shadowColor = color.cgColor
            self.layer.shadowOpacity = opacity
            self.layer.shadowRadius = radius
            self.layer.shadowOffset = CGSize(width: 0, height: 0) // Không dịch bóng về hướng nào

            if spread == 0 {
                self.layer.shadowPath = nil
            } else {
                let rect = self.bounds.insetBy(dx: -spread, dy: -spread) // Mở rộng shadow ra ngoài view
                self.layer.shadowPath = UIBezierPath(rect: rect).cgPath
            }
        }
    
    func shakeLight() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.5
        animation.values = [-5.0, 5.0, -3.0, 3.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
    
    func bubble(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.5, options: .curveEaseIn) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        } completion: { _ in
            UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 3, options: .curveEaseIn) {
                self.transform = .identity
            } completion: { _ in
                completion?()
            }
        }
    }
}


extension UIImage{
    
    //creates a UIImage given a UIColor
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
