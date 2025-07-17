//
//  CoreDataManager.swift


import UIKit
import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    
    private var managedContext: NSManagedObjectContext?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "speakAI")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private init() {
        self.managedContext = self.persistentContainer.viewContext
    }
    
    //MARK: - Folders
    
    @discardableResult
    func saveFolder(folderObj: FolderObj) -> NSManagedObjectID? {
        guard let managedContext = self.managedContext else {
            return nil
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Folders", in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        folderObj.saveToLibraryCoreData(object: object)
        
        do {
            try managedContext.save()
            print("SAVE COREDATA")
            return object.objectID // Trả về objectID sau khi lưu
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func fecthAllFolders() -> [FolderObj] {
        var data: [FolderObj] = []
        
        guard let managedContext = self.managedContext else {
            return data
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Folders")
        
        let sectionSortDescriptor = NSSortDescriptor(key: "order", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try managedContext.fetch(fetchRequest)
            data = results.compactMap({ FolderObj.init(object: $0) })
            print("data--->",data)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return data
    }
    
    func deleteFolder(withID id: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let objects = try managedContext.fetch(fetchRequest) as? [NSManagedObject], let objectToDelete = objects.first {
                managedContext.delete(objectToDelete)
                try managedContext.save()
                print("Deleted folder with ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func getInfoFolder(withID id: String) -> FolderObj? {
        guard let managedContext = self.managedContext else {
            return nil
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let object = objects.first {
                return FolderObj(object: object) // Convert NSManagedObject to FolderObj
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil // Return nil if nothing is found
    }
    
    
    func updateOrderFolder(withID id: String, order: Int) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(order, forKey: "order")
                try managedContext.save()
                print("Updated folder with ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func updateNameFolder(withID id: String, name: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Folders")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(name, forKey: "name")
                try managedContext.save()
                print("Updated folder with ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func updateFolderOrderInCoreData(_ folders: [FolderObj]) {
        guard let managedContext = self.managedContext else { return }
        var indexPos = 1
        for (index, folderObj) in folders.enumerated() {
            print("folderObj--->",folderObj.name, index)
            indexPos = indexPos + 1
            _ = self.updateOrderFolder(withID: folderObj.id, order: indexPos)
        }
        
        do {
            try managedContext.save()
            print("Updated folder order in Core Data")
        } catch {
            print("Failed to save order updates: \(error)")
        }
    }
    
    
    //MARK: - Records
    
    func saveRecord(record: RecordsObj) -> NSManagedObjectID? {
        guard let managedContext = self.managedContext else {
            return nil
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "Records", in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        record.saveToLibraryCoreData(object: object)
        
        do {
            try managedContext.save()
            print("SAVE CORE DATA")
            return object.objectID // Trả về objectID sau khi lưu
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    func deleteRecord(withID id: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Records")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            if let objects = try managedContext.fetch(fetchRequest) as? [NSManagedObject], let objectToDelete = objects.first {
                managedContext.delete(objectToDelete)
                try managedContext.save()
                print("Deleted folder with ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func updateRecord(record: RecordsObj) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Records")
        fetchRequest.predicate = NSPredicate(format: "id == %@", record.id)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(record.title, forKey: "title")
                objectToUpdate.setValue(record.transcription, forKey: "transcription")
                objectToUpdate.setValue(record.emoji, forKey: "emoji")
                objectToUpdate.setValue(record.is_later, forKey: "is_later")
                try managedContext.save()
                print("Updated Records with ID: \(record.id)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    func updateTranscriptionRecord(transcription: String, recordId: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Records")
        fetchRequest.predicate = NSPredicate(format: "id == %@", recordId)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(transcription, forKey: "transcription")
                try managedContext.save()
                print("Updated Records with ID: \(recordId)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    func updateFolderRecord(recordID: String, folderId: String ) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Records")
        fetchRequest.predicate = NSPredicate(format: "id == %@", recordID)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(folderId, forKey: "folderId")
                try managedContext.save()
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    //MARK: - RecordActions
    
    
    func saveRecordActions(record: RecordActionObj) -> NSManagedObjectID? {
        guard let managedContext = self.managedContext else {
            return nil
        }
        
        let entity = NSEntityDescription.entity(forEntityName: "RecordActions", in: managedContext)!
        let object = NSManagedObject(entity: entity, insertInto: managedContext)
        
        record.saveToLibraryCoreData(object: object)
        
        do {
            try managedContext.save()
            print("SAVE CORE DATA")
            return object.objectID // Trả về objectID sau khi lưu
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
    }
    
    
    func fetchAllRecordsGroupedByHumanReadableDate(searchText: String?) -> [String: [RecordsObj]] {
        var groupedData: [String: [RecordsObj]] = [:]
        
        guard let managedContext = self.managedContext else {
            return groupedData
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Records")
        let sectionSortDescriptor = NSSortDescriptor(key: "createAt", ascending: false)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        
        if let searchText = searchText, !searchText.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "title CONTAINS[cd] %@ OR transcription CONTAINS[cd] %@", searchText, searchText)
        }
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let records = results.compactMap { RecordsObj(object: $0) }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let calendar = Calendar.current
            
            groupedData = Dictionary(grouping: records) { record in
                let date = Date(timeIntervalSince1970: record.createAt)
                if calendar.isDateInToday(date) {
                    return "Today"
                } else if calendar.isDateInYesterday(date) {
                    return "Yesterday"
                } else {
                    return formatter.string(from: date)
                }
            }
            
            // Sắp xếp lại mỗi group theo thời gian mới nhất
            for (key, value) in groupedData {
                groupedData[key] = value.sorted(by: { $0.createAt > $1.createAt })
            }
            
        } catch let error as NSError {
            print("❌ Could not fetch. \(error), \(error.userInfo)")
        }
        
        return groupedData
    }

    
    func fetchAllRecords() -> [RecordsObj] {
        var records: [RecordsObj] = []
        
        guard let managedContext = self.managedContext else {
            return records
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Records")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createAt", ascending: false)]
        do {
            let results = try managedContext.fetch(fetchRequest)
            records = results.compactMap { RecordsObj(object: $0) }
        } catch {
            print("❌ Error fetching records:", error)
        }
        
        return records
    }
    
    
    func deleteAllRecords() {
        guard let managedContext = self.managedContext else { return }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Records")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            print("✅ All records deleted successfully.")
        } catch {
            print("❌ Failed to delete records: \(error)")
        }
    }
    
    
    func deleteAllRecordActions() {
        guard let managedContext = self.managedContext else { return }
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "RecordActions")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try managedContext.execute(deleteRequest)
            try managedContext.save()
            print("✅ All records deleted successfully.")
        } catch {
            print("❌ Failed to delete records: \(error)")
        }
    }
    
    func fetchAllRecordsGroupedByFolder(folderId: String, searchText: String?) -> [String: [RecordsObj]] {
        var groupedData: [String: [RecordsObj]] = [:]
        
        guard let managedContext = self.managedContext else {
            return groupedData
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Records")
        
        let sectionSortDescriptor = NSSortDescriptor(key: "createAt", ascending: false)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        
        var predicates: [NSPredicate] = []
        
        // Điều kiện lọc theo folderId
        predicates.append(NSPredicate(format: "folderId == %@", folderId))
        
        // Nếu có searchText, thêm điều kiện lọc
        if let searchText = searchText, !searchText.isEmpty {
            let searchPredicate = NSPredicate(format: "title CONTAINS[cd] %@ OR transcription CONTAINS[cd] %@", searchText, searchText)
            predicates.append(searchPredicate)
        }
        
        // Kết hợp tất cả các điều kiện lọc
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            let records = results.compactMap { RecordsObj(object: $0) }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            
            let calendar = Calendar.current
            
            groupedData = Dictionary(grouping: records) { record in
                let date = Date(timeIntervalSince1970: record.createAt)
                
                if calendar.isDateInToday(date) {
                    return "Today"
                } else if calendar.isDateInYesterday(date) {
                    return "Yesterday"
                } else {
                    return formatter.string(from: date)
                }
            }
            
            // Sắp xếp lại mỗi group theo thời gian mới nhất
            for (key, value) in groupedData {
                groupedData[key] = value.sorted(by: { $0.createAt > $1.createAt })
            }
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        return groupedData
    }
    
    func updateReadRecord(withID id: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Records")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(true, forKey: "is_read")
                try managedContext.save()
                print("updateReadRecord ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func updateLaterRecord(withID id: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Records")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(true, forKey: "is_later")
                try managedContext.save()
                print("updateLaterRecord ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func fetchRecordActions(recordId: String) -> [RecordActionObj] {
        var data: [RecordActionObj] = []
        
        guard let managedContext = self.managedContext else {
            return data
        }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "RecordActions")
        fetchRequest.predicate = NSPredicate(format: "recordId == %@", recordId)
        let sectionSortDescriptor = NSSortDescriptor(key: "action", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        do {
            let results = try managedContext.fetch(fetchRequest)
            
            data = results.compactMap({ RecordActionObj.init(object: $0) })
            print(data)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return data
    }
    
    
    func updatTextRecordAction(withID id: String, action: Int, text: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "RecordActions")
        fetchRequest.predicate = NSPredicate(format: "recordId == %@ AND action == %d", id, action)
        
        do {
            let objects = try managedContext.fetch(fetchRequest)
            if let objectToUpdate = objects.first {
                objectToUpdate.setValue(text, forKey: "text")
                objectToUpdate.setValue(action, forKey: "action")
                try managedContext.save()
                print("updatTextRecordAction ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not update. \(error), \(error.userInfo)")
        }
        return false
    }
    
    func deleteRecordActions(withID id: String) -> Bool {
        guard let managedContext = self.managedContext else {
            return false
        }
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "RecordActions")
        fetchRequest.predicate = NSPredicate(format: "recordId == %@", id)
        
        do {
            if let objects = try managedContext.fetch(fetchRequest) as? [NSManagedObject] {
                for object in objects {
                    managedContext.delete(object)
                }
                
                try managedContext.save()
                print("Deleted folder with ID: \(id)")
                return true
            }
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        return false
    }
    
    
    func updateAllRecordFromFolderToFolderAll(folderId: String, folderMoveId: String) {
        
        guard let managedContext = self.managedContext else {
            return
        }
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Records")
        
        let sectionSortDescriptor = NSSortDescriptor(key: "createAt", ascending: false)
        fetchRequest.sortDescriptors = [sectionSortDescriptor]
        fetchRequest.predicate = NSPredicate(format: "folderId == %@", folderId)
        do {
            let objects = try managedContext.fetch(fetchRequest)
            for object in objects {
                object.setValue(folderMoveId, forKey: "folderId")
                try managedContext.save()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}
