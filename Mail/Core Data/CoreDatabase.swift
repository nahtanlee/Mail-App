//
//  LoginViewModel.swift
//  Mail
//
//  Created by Nathan Lee on 4/1/2024.
//

import CoreData
import SwiftUI

struct CoreDatabase {
    var managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    func read(entity: String, attribute: String) -> String? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if let attributeValue = data.value(forKey: attribute) as? String {
                    return attributeValue
                }
            }
        } catch {
            print("Failed to fetch data")
        }
        return nil
    }

    func write(entity: String, attribute: String, value: Any) {
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        let newRecord = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        newRecord.setValue(value, forKey: attribute)
        do {
            try managedObjectContext.save()
        } catch {
            print("Failed to save data")
        }
    }
}
