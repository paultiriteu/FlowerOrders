//
//  PersistenceManager.swift
//  FlowerOrders
//
//  Created by Paul Tiriteu on 05/08/2020.
//  Copyright © 2020 Paul Tiriteu. All rights reserved.
//

import CoreData

final class PersistenceManager {
    public typealias ManagedObjectContextWithObject<O: NSManagedObject> = (NSManagedObjectContext, O?) -> Void
    static let shared = PersistenceManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlowerOrders")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var context = persistentContainer.viewContext
    
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        persistentContainer.performBackgroundTask(block)
    }
}


public extension NSManagedObjectContext {
    func saveContext () {
        if hasChanges {
            do {
                try save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, id: Double) -> T? {
        guard let intId = Int(exactly: id) else { return nil }
        return fetch(type, predicate: NSPredicate(format: "uid == %d", intId))?.first
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate? = nil) -> [T]? {
        let entityName = String(describing: T.self)
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        return try? fetch(fetchRequest)
    }
    
    func itemExists<T: NSManagedObject>(id: Double, type: T.Type) -> Bool {
        return fetch(type, id: id) != nil
    }
    
    func deleteAll<T: NSManagedObject>(_ type: T.Type) {
        guard let entities = fetch(type) else { return }
        for entity in entities {
            delete(entity)
        }
    }
}
