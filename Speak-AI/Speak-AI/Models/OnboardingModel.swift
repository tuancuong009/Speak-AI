//
//  OnboardingModel.swift
//  Einstein AI
//
//  Created by QTS Coder on 22/1/25.
//

import UIKit
class OnboardingModel: NSObject{
    var image: UIImage = UIImage.init()
    var title = ""
    var desc = ""
    init(image: UIImage, title: String = "", desc: String = "") {
        self.image = image
        self.title = title
        self.desc = desc
    }
}
