//
//  LanguageAssemblyAI.swift
//  Speak-AI
//
//  Created by QTS Coder on 14/3/25.
//

import Foundation

class LanguageAssemblyAI{
    static let shared = LanguageAssemblyAI()
    func listLanguageSupport()-> [LanguageModel]{
        if let path = Bundle.main.path(forResource: "AssemblyAI", ofType: "json") {
            do {
                var lists = [LanguageModel]()
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                // let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResults = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [NSDictionary]{
                    for jsonResult in jsonResults {
                        lists.append(LanguageModel(jsonResult))
                    }
                    return lists
                }
            } catch {
                print("Error--->",error)
                // handle error
            }
        }
        return []
    }
    
    func firstLanguage()-> LanguageModel?{
        let lists = self.listLanguageSupport()
        for list in lists {
            if list.code == AppSetings.shared.getLanguageDefault(){
                return list
            }
        }
        return lists.count > 0 ? lists[0] : nil
    }
}
