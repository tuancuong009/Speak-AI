//
//  OnboardingCollectionViewCell.swift
//  Einstein AI
//
//  Created by QTS Coder on 22/1/25.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgSlide: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func setup(_ model: OnboardingModel){
        lblTitle.text = model.title
        lblDesc.text = model.desc
        imgSlide.image = model.image
    }
}
