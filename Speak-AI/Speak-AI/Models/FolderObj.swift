//
//  FolderObj.swift
//  Speak-AI
//
//  Created by QTS Coder on 18/3/25.
//

import Foundation
import CoreData
struct FolderObj: Codable{
    var id: String
    var name: String
    var order: Int
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case order
    }
}
extension FolderObj {
    
    init(object: NSManagedObject) {
        self.id = object.string(forKey: "id") ?? ""
        self.name = object.string(forKey: "name") ?? ""
        self.order = object.int(forKey: "order") ?? 0
    }
    
    
    
    func saveToLibraryCoreData(object: NSManagedObject) {
        object.setValue(id, forKey: "id")
        object.setValue(name, forKey: "name")
        object.setValue(order, forKey: "order")
    }
}
