//
//  UIButtonExtensions.swift
//

import UIKit

class DSButton: UIButton {
    
    @IBInspectable
    var minScale: CGFloat = 1.0 {
        didSet {
            self.titleLabel?.adjustsFontSizeToFitWidth = true
            self.titleLabel?.minimumScaleFactor = minScale
        }
    }
}

extension UIButton {
    func setButtonTile(title: String?) {
        self.titleLabel?.text = title
        self.setTitle(title, for: .normal)
    }
}
typealias ButtonAction = () -> Void

extension UIButton {
    
    private struct AssociatedKeys {
        static var ActionKey = "ActionKey"
    }
    
    private class ActionWrapper {
        let action: ButtonAction
        init(action: @escaping ButtonAction) {
            self.action = action
        }
    }
    
    var action: ButtonAction? {
        set(newValue) {
            removeTarget(self, action: #selector(performAction), for: .touchUpInside)
            var wrapper: ActionWrapper? = nil
            if let newValue = newValue {
                wrapper = ActionWrapper(action: newValue)
                addTarget(self, action: #selector(performAction), for: .touchUpInside)
            }
            
            objc_setAssociatedObject(self, &AssociatedKeys.ActionKey, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            guard let wrapper = objc_getAssociatedObject(self, &AssociatedKeys.ActionKey) as? ActionWrapper else {
                return nil
            }
            
            return wrapper.action
        }
    }
    
    @objc func performAction() {
        guard let action = action else {
            return
        }

        action()
    }
}
