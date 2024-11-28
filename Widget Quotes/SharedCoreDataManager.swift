//
//  SharedCoreDataManager.swift
//  Widget Quotes
//
//  Created by Oren Lindsey on 11/28/24.
//
import CoreData
class SharedCoreDataManager {
    static let shared = SharedCoreDataManager()
    
    private init() {}

    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Widgets") // Replace with your .xcdatamodel name
        let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.studio.lindsey.Widget-Quotes.Quotes")!.appendingPathComponent("Widgets.sqlite")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        return container
    }()

    var viewContext: NSManagedObjectContext {
        return Self.persistentContainer.viewContext
    }
}
