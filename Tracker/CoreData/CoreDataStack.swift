import CoreData

final class CoreDataStack {

    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {

        persistentContainer = NSPersistentContainer(
            name: "TrackerModel"
        )

        persistentContainer.loadPersistentStores { _, error in

            if let error = error {

                fatalError(
                    "Не удалось загрузить Core Data: \(error)"
                )
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

            print(
                "Ошибка сохранения: \(error)"
            )
        }
    }
}
