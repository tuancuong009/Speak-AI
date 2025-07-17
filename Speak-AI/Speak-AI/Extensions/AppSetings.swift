//
//  Untitled.swift
//  Speak-AI
//
//  Created by QTS Coder on 14/3/25.
//

import UIKit

class AppSetings{
    static let shared = AppSetings()
    func updateOnboarding(){
        UserDefaults.standard.set(true, forKey: KeyDefaults.Onboading)
        UserDefaults.standard.synchronize()
    }
    
    var isOnboading: Bool{
        return UserDefaults.standard.bool(forKey: KeyDefaults.Onboading)
    }
    
    func updateUntitled(){
        var count = 1
        if let number = UserDefaults.standard.value(forKey: KeyDefaults.UnititledNote) as? Int{
            count = number + 1
        }
        else{
            count = 2
        }
        UserDefaults.standard.set(count, forKey: KeyDefaults.UnititledNote)
        UserDefaults.standard.synchronize()
    }
    
    func getUnititledNote()-> Int{
        if let number = UserDefaults.standard.value(forKey: KeyDefaults.UnititledNote) as? Int{
            return number
        }
        return 1
    }
    
    func updateLanguageDefault(_ languageCode: String){
        UserDefaults.standard.set(languageCode, forKey: KeyDefaults.languageSpeak)
        UserDefaults.standard.synchronize()
    }
    
    
    
    func getLanguageDefault()->String{
        return UserDefaults.standard.value(forKey: KeyDefaults.languageSpeak) as? String ?? ""
    }
    

    
    
    func isValidLanguageDefault(){
        if (UserDefaults.standard.value(forKey: KeyDefaults.languageSpeak) == nil){
            updateLanguageDefault("AutoDetect")
        }
    }
    
    func checkIsAutoLanguage(_ code: String)->(Bool, String){
        if  code == "AutoDetect"{
            return (true,"AutoDetect")
        }
        else{
            return (false,code)
        }
    }
}
