//
//  AnimatedButton.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//


import UIKit

class AnimatedButton: UIButton {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        self.addTarget(self, action: #selector(pressDown), for: .touchDown)
        self.addTarget(self, action: #selector(releaseButton), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func pressDown() {
        UIView.animate(withDuration: 0.1) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            self.alpha = 0.8
        }
    }

    @objc private func releaseButton() {
        UIView.animate(withDuration: 0.1) {
            self.transform = .identity
            self.alpha = 1.0
        }
    }
}