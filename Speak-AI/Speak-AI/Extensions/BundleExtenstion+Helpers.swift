//
//  BundleExtenstion+Helpers.swift
//

import UIKit

extension Bundle {
    
    var appVersion: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    static var mainAppVersion: String? {
        Bundle.main.appVersion
    }
    
    static func versionApp() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let buildVersion = dictionary["CFBundleVersion"] as! String
        return "\(version) (\(buildVersion))"
    }
    
    
    /// let items = Bundle.main.decode([TourItem].self, from: "Tour.json")
    func decode<T: Decodable>(_ type: T.Type, from filename: String) -> T {
        guard let json = url(forResource: filename, withExtension: nil) else {
            fatalError("Failed to locate \(filename) in app bundle.")
        }
        
        guard let jsonData = try? Data(contentsOf: json) else {
            fatalError("Failed to load \(filename) from app bundle.")
        }
        
        let decoder = JSONDecoder()
        
        guard let result = try? decoder.decode(T.self, from: jsonData) else {
            fatalError("Failed to decode \(filename) from app bundle.")
        }
        
        return result
    }
    
    var appName: String? {
        self.infoDictionary?["CFBundleName"] as? String
    }
    
    func getValueForKey(key: String) -> String? {
        return self.infoDictionary?[key] as? String
    }
}
