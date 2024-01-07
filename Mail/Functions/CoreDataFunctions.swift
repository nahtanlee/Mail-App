import CoreData
import SwiftUI

struct CoreDatabase {
    var managedObjectContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }

    func read<T>(entity: String, attribute: String, completion: @escaping (T?) -> Void) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        do {
            let result = try managedObjectContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                if let attributeValue = data.value(forKey: attribute) as? T {
                    completion(attributeValue)
                    return
                }
            }
        } catch {
            print("Failed to fetch data: \(error)")
        }
        completion(nil)
    }

    
    func write(entity: String, attribute: String, value: Any, completion: @escaping (Bool) -> Void) {
        let entity = NSEntityDescription.entity(forEntityName: entity, in: managedObjectContext)
        let newRecord = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
        newRecord.setValue(value, forKey: attribute)
        do {
            try managedObjectContext.save()
            completion(true)
        } catch {
            print("Failed to save data")
            completion(false)
        }
    }
    

}
