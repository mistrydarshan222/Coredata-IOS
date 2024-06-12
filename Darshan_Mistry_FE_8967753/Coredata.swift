//
//  Coredata.swift
//  Darshan_Mistry_FE_8967753
//
//  Created by user236106 on 4/18/24.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "YourDataModelName")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        })
        return container
    }()
    
    func preloadData() {
        let cities = ["Toronto", "Montreal", "Vancouver", "Calgary", "Ottawa"]
        let context = persistentContainer.viewContext
        
        for cityName in cities {
            let searchHistory = SearchHistory(context: context)
            searchHistory.cityName = cityName
            searchHistory.interactionType = "Search"
            searchHistory.timestamp = Date()
        }
        
        saveContext()
    }
    
    func saveContext() {
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

