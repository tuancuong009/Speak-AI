//
//  LanguageTableViewCell.swift
//  Speak-AI
//
//  Created by QTS Coder on 7/2/25.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var imgFlat: UIImageView!
    @IBOutlet weak var bgCell: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var icSelect: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
