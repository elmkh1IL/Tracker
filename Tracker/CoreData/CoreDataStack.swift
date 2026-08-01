import CoreData
import OSLog

final class CoreDataStack {

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Tracker",
        category: "CoreDataStack"
    )
    
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {

        persistentContainer = NSPersistentContainer(
            name: "TrackerModel"
        )

        persistentContainer.loadPersistentStores { _, error in

            if let error = error {
                
                self.logger.fault(
                    "Не удалось загрузить Core Data: \(error.localizedDescription)")
                
                preconditionFailure("Core Data initialization failed")
            }
        }
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {

        guard context.hasChanges else {
            return
        }

        do {

            try context.save()

        } catch {

            logger.error("Ошибка сохранения: \(error)"
            )
        }
    }
}
