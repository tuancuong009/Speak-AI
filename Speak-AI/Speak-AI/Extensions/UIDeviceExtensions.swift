//
//  UIDeviceExtensions.swift
//

import UIKit

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let identifier = Mirror(reflecting: systemInfo.machine).children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
            switch identifier {
            // iPhone
            case "iPhone14,2": return "iPhone 13 Pro"
            case "iPhone14,3": return "iPhone 13 Pro Max"
            case "iPhone14,4": return "iPhone 13 mini"
            case "iPhone14,5": return "iPhone 13"
            case "iPhone14,6": return "iPhone SE (3rd generation)"
            case "iPhone15,2": return "iPhone 14 Pro"
            case "iPhone15,3": return "iPhone 14 Pro Max"
            case "iPhone14,7": return "iPhone 14"
            case "iPhone14,8": return "iPhone 14 Plus"
            case "iPhone16,1": return "iPhone 15 Pro"
            case "iPhone16,2": return "iPhone 15 Pro Max"
            case "iPhone15,4": return "iPhone 15"
            case "iPhone15,5": return "iPhone 15 Plus"
            
            // iPad (thêm các model mới)
            case "iPad14,3", "iPad14,4": return "iPad Pro 11-inch (4th generation)"
            case "iPad14,5", "iPad14,6": return "iPad Pro 12.9-inch (6th generation)"
            case "iPad14,8", "iPad14,9": return "iPad Air (5th generation)"
            case "iPad15,3", "iPad15,4": return "iPad Pro 11-inch (5th generation)"
            case "iPad15,5", "iPad15,6": return "iPad Pro 12.9-inch (7th generation)"
            
            // Simulator
            case "i386", "x86_64", "arm64":
                return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            
            default: return identifier
            }
            #else
            return identifier
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }
}
