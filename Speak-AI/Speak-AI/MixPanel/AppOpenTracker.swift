//
//  AppOpenTracker.swift
//  Speak-AI
//
//  Created by QTS Coder on 13/8/25.
//


import Foundation

class AppOpenTracker {
    static let shared = AppOpenTracker()
    private init() {}
    
    private let key = "firstAppOpenDate"
    private let defaults = UserDefaults.standard
    
    func saveFirstAppOpenDateIfNeeded() {
        if defaults.string(forKey: key) == nil {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())
            
            defaults.set(dateString, forKey: key)
            defaults.synchronize()
            
            print("📅 First app open date saved:", dateString)
        }
    }
    
    func getFirstAppOpenDate() -> String? {
        return defaults.string(forKey: key)
    }
    
    func formatDateSubs(date: Date)-> String{
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        return dateString
    }
}
