//
//  LanguageModel.swift
//  Speak-AI
//
//  Created by QTS Coder on 14/3/25.
//
import UIKit
class LanguageModel: NSObject{
    var name = ""
    var code = ""
    var img = ""
    var isBest = false
    init(_ dict: NSDictionary) {
        self.name = dict.object(forKey: "Language") as? String ?? ""
        self.code = dict.object(forKey: "LanguageCode") as? String ?? ""
        self.isBest = dict.object(forKey: "IsBest") as? Bool ?? false
        self.img = dict.object(forKey: "Img") as? String ?? ""
    }
}
