//
//  FinderManager.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import CoreData

final class FinderManager {
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Finder")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    init() {
        _ = insertRootFolderIfNeed()
    }
    
    func new<T: Item>() -> T {
        let item =  NSEntityDescription.insertNewObject(forEntityName: String(describing: T.self), into: persistentContainer.viewContext) as! T
        item.id = UUID()
        item.name = ""
        return item
    }
    
    func insertRootFolderIfNeed() -> Folder {
        let request = NSFetchRequest<Folder>(entityName: "Folder")
        let predicate = NSPredicate(format: "isRoot == TRUE")
        request.predicate = predicate
        if let folder = try? persistentContainer.viewContext.fetch(request).first {
            return folder
        } else {
            let rootFolder:Folder = new()
            rootFolder.isRoot = true
            return rootFolder
        }
    }
    
    func fetch<T: Item>(id: UUID) -> T? {
        let request = T.fetchRequest()
        let predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.predicate = predicate
        return try! persistentContainer.viewContext.fetch(request).compactMap({ $0 as? T}).first
    }
    
    private func fetch() -> [Item] {
        let request = Item.fetchRequest()
        return try! persistentContainer.viewContext.fetch(request)
    }
    
    func delete(id: UUID) {
        guard let item = fetch(id: id) else { return }
        persistentContainer.viewContext.delete(item)
        save()
    }
    
    func deleteAll() {
        let allItems = fetch()
        allItems.forEach({ persistentContainer.viewContext.delete($0) })
        save()
    }
    
    func save() {
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
}
