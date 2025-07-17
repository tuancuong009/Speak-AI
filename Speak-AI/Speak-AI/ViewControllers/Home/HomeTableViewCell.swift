import UIKit

class HomeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var folderLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var viewContent: UIView!

    private let gradientLayer = CAGradientLayer()

    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradientBorder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        DispatchQueue.main.async {
            self.updateGradientBorder()
        }
    }

    /// ✅ Tạo viền gradient ban đầu
    private func setupGradientBorder() {
        gradientLayer.colors = [UIColor.orange.cgColor, UIColor.purple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 16

        viewContent.layer.insertSublayer(gradientLayer, at: 0)
    }

    /// ✅ Cập nhật khung gradient (GỌI TRONG `layoutSubviews`)
    private func updateGradientBorder() {
        gradientLayer.frame = viewContent.bounds  // 🔥 Đảm bảo kích thước gradient khớp với viewContent
        gradientLayer.cornerRadius = viewContent.layer.cornerRadius // 🔥 Cập nhật cornerRadius

        let shape = CAShapeLayer()
        shape.path = UIBezierPath(roundedRect: viewContent.bounds, cornerRadius: 16).cgPath
        shape.lineWidth = 3
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor

        gradientLayer.mask = shape
    }

    /// ✅ Cập nhật nội dung cell và kiểm tra trạng thái `is_read`
    public func configCell(record: RecordsObj) {
        descLabel.text = record.transcription
        folderLabel.text  = CoreDataManager.shared.getInfoFolder(withID: record.folderId)?.name
        timeLabel.text = TimeHelper.shared.formatTime(record.createAt)
        emojiLabel.text = record.emoji.isEmpty ? "🔴" : record.emoji
        titleLabel.text = record.title.isEmpty ? "Untitled Note" : record.title

        print("record.is_read -->", record.is_read)

        if record.is_read {
            gradientLayer.removeFromSuperlayer() // ✅ Xóa viền nếu đã đọc
        } else {
            if gradientLayer.superlayer == nil {
                viewContent.layer.insertSublayer(gradientLayer, at: 0) // ✅ Thêm lại nếu chưa có
            }
        }

        setNeedsLayout() // ✅ Gọi lại layout
        layoutIfNeeded()
    }
}
