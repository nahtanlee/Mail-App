//
//  PersistenceController.swift
//  Mail
//
//  Created by Nathan Lee on 3/1/2024.
//

import Foundation
import SwiftUI
import CoreData

struct PersistenceController {
    // A singleton for our entire app to use
    static let shared = PersistenceController()

    // Storage for Core Data
    let container: NSPersistentContainer

    // An initializer to load Core Data, optionally able to use an in-memory store.
    init(inMemory: Bool = false) {
        
        container = NSPersistentContainer(name: "Data")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        let context = container.viewContext
        
        let loginEntity = NSEntityDescription.entity(forEntityName: "Login", in: context)!
        let newObject = NSManagedObject(entity: loginEntity, insertInto: context)
        
        newObject.setValue(true, forKey: "setup")
        
        save()
        
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
                print("Error saving context: \(error)")            }
        }
    }
}

