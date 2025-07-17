//
//  RecordsObj.swift
//  Speak-AI
//
//  Created by QTS Coder on 18/3/25.
//

import CoreData
struct RecordsObj: Codable{
    var id: String
    var file: String
    var createAt: Double
    var folderId: String
    var title: String
    var transcription: String
    var emoji: String
    var is_later: Bool
    var is_read: Bool
    var language_code: String
    var filesize: Double
    enum CodingKeys: String, CodingKey {
        case id
        case file
        case createAt
        case folderId
        case title
        case transcription
        case emoji
        case is_later
        case is_read
        case language_code
        case filesize
    }
}
extension RecordsObj {
    
    init(object: NSManagedObject) {
        self.id = object.string(forKey: "id") ?? ""
        self.file = object.string(forKey: "file") ?? ""
        self.createAt = object.double(forKey: "createAt") ?? 0.0
        self.folderId = object.string(forKey: "folderId") ?? ""
        self.title = object.string(forKey: "title") ?? ""
        self.transcription = object.string(forKey: "transcription") ?? ""
        self.emoji = object.string(forKey: "emoji") ?? ""
        self.is_later = object.bool(forKey: "is_later") ?? false
        self.is_read = object.bool(forKey: "is_read") ?? false
        self.language_code = object.string(forKey: "language_code") ?? ""
        self.filesize = object.double(forKey: "filesize") ?? 0.0
    }
    
    
    
    func saveToLibraryCoreData(object: NSManagedObject) {
        object.setValue(id, forKey: "id")
        object.setValue(file, forKey: "file")
        object.setValue(createAt, forKey: "createAt")
        object.setValue(folderId, forKey: "folderId")
        object.setValue(title, forKey: "title")
        object.setValue(transcription, forKey: "transcription")
        object.setValue(emoji, forKey: "emoji")
        object.setValue(is_later, forKey: "is_later")
        object.setValue(is_read, forKey: "is_read")
        object.setValue(language_code, forKey: "language_code")
        object.setValue(filesize, forKey: "filesize")
    }
}



struct RecordActionObj:Codable{
    var action: Int
    var recordId: String
    var text: String
    var textAI: String
    var id: String
    enum CodingKeys: String, CodingKey {
        case action
        case recordId
        case text
        case textAI
        case id
    }
}

extension RecordActionObj {
    
    init(object: NSManagedObject) {
        self.action = object.int(forKey: "action") ?? 0
        self.textAI = object.string(forKey: "textAI") ?? ""
        self.recordId = object.string(forKey: "recordId") ?? ""
        self.text = object.string(forKey: "text") ?? ""
        self.id =  object.string(forKey: "id") ?? ""
    }
    
    
    
    func saveToLibraryCoreData(object: NSManagedObject) {
        object.setValue(action, forKey: "action")
        object.setValue(recordId, forKey: "recordId")
        object.setValue(text, forKey: "text")
        object.setValue(textAI, forKey: "textAI")
        object.setValue(id, forKey: "id")
    }
}
