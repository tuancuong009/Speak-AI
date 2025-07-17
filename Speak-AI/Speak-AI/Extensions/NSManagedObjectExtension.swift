//
//  NSManagedObjectExtension.swift
//  Skalet
//
//  Created by Skalet on 13/03/2024.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    func arrayDictionary(forKey: String) -> [NSDictionary]? {
        return self.value(forKey: forKey) as? [NSDictionary]
    }
    
    func dictionary(forKey: String) -> NSDictionary? {
        return self.value(forKey: forKey) as? NSDictionary
    }
    
    func string(forKey: String) -> String? {
        return self.value(forKey: forKey) as? String
    }
    
    func arrayString(forKey: String) -> [String]? {
        return self.value(forKey: forKey) as? [String]
    }
    
    func int(forKey: String) -> Int? {
        return self.value(forKey: forKey) as? Int
    }
    
    func int64(forKey: String) -> Int64? {
        return self.value(forKey: forKey) as? Int64
    }
    
    func arrayInt(forKey: String) -> [Int]? {
        return self.value(forKey: forKey) as? [Int]
    }
    
    func double(forKey: String) -> Double? {
        return self.value(forKey: forKey) as? Double
    }
    
    func float(forKey: String) -> Float? {
        return self.value(forKey: forKey) as? Float
    }
    
    func bool(forKey: String) -> Bool? {
        return self.value(forKey: forKey) as? Bool
    }
    
    func date(forKey: String) -> Date? {
        return self.value(forKey: forKey) as? Date
    }
    
}
