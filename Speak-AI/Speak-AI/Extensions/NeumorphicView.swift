import UIKit

class NeumorphicView: UIView {
    private let bottomShadow = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupNeumorphicEffect()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNeumorphicEffect()
    }
    
    private func setupNeumorphicEffect() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = false

        // Viền màu xám nhẹ
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.3).cgColor

        // Bóng trên (trắng nhẹ)
        self.layer.shadowColor = UIColor.white.cgColor
        self.layer.shadowOffset = CGSize(width: -3, height: -3)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 5
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
        
        // Bóng dưới (xám nhạt)
        bottomShadow.cornerRadius = self.layer.cornerRadius
        bottomShadow.backgroundColor = UIColor.white.cgColor
        bottomShadow.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
        bottomShadow.shadowOffset = CGSize(width: 3, height: 3)
        bottomShadow.shadowOpacity = 1
        bottomShadow.shadowRadius = 5
        
        self.layer.insertSublayer(bottomShadow, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Đảm bảo shadow path được cập nhật khi frame thay đổi
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
        bottomShadow.frame = self.bounds
    }
}
