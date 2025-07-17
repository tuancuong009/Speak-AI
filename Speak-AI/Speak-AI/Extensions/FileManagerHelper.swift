//
//  FileManager.swift
//  Speak-AI
//
//  Created by QTS Coder on 18/3/25.
//

import Foundation
class FileManagerHelper{
    static let shared = FileManagerHelper()
    func getDocumentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func saveFileToLocal(data: Data, fileName: String, folderName: String) -> URL? {
        let folderURL = getDocumentsDirectory().appendingPathComponent(folderName)

        // Create folder if it doesn't exist
        if !FileManager.default.fileExists(atPath: folderURL.path) {
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true)
            } catch {
                print("❌ Error creating folder: \(error)")
                return nil
            }
        }

        let fileURL = folderURL.appendingPathComponent(fileName)

        do {
            try data.write(to: fileURL)
            print("✅ File saved successfully at: \(fileURL)")
            
            // ✅ Verify file exists
            if FileManager.default.fileExists(atPath: fileURL.path) {
                print("✅ File exists after saving.")
            } else {
                print("❌ File does not exist after saving.")
                return nil
            }
            
            return fileURL
        } catch {
            print("❌ Error saving file: \(error)")
            return nil
        }
    }
    
    func fileExists(fileName: String, folderName: String) -> Bool {
        let fileURL = getDocumentsDirectory().appendingPathComponent(folderName).appendingPathComponent(fileName)
        return FileManager.default.fileExists(atPath: fileURL.path)
    }
    
    func listFilesInFolder(folderName: String) -> [String] {
        let folderURL = getDocumentsDirectory().appendingPathComponent(folderName)
        
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: folderURL.path)
            return files
        } catch {
            print("Error list file: \(error)")
            return []
        }
    }
    
    func deleteFile(fileName: String, folderName: String) {
        let fileURL = getDocumentsDirectory().appendingPathComponent(folderName).appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("File delete: \(fileName)")
            } catch {
                print("Error delete file: \(error)")
            }
        } else {
            print("File Not exit!")
        }
    }
    
    
    func getFile(fileName: String, folderName: String) -> URL? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(folderName).appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            print("File exit!-->",fileURL.path)
            return fileURL
        } else {
            print("File Not exit!")
            return nil
        }
    }
}
