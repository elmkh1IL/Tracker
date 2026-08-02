import CoreData
import OSLog

protocol TrackerCategoryStoreDelegate: AnyObject {

    func didUpdate()
}

final class TrackerCategoryStore: NSObject {
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Tracker",
        category: "TrackerCategoryStore")

    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext

    private let fetchedResultsController:
        NSFetchedResultsController<TrackerCategoryCoreData>

    init(context: NSManagedObjectContext) {

        self.context = context

        let request: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "title",
                ascending: true
            )
        ]

        fetchedResultsController =
            NSFetchedResultsController(
                fetchRequest: request,
                managedObjectContext: context,
                sectionNameKeyPath: nil,
                cacheName: nil
            )

        super.init()

        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            logger.error("Ошибка: \(error.localizedDescription)")
        }
    }
    
    var categories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }

        return objects.map { category in
            TrackerCategory(
                title: category.title ?? "",
                trackers: []
            )
        }
    }
    
    func addCategory(title: String) {

        let category = TrackerCategoryCoreData(context: context)
        category.title = title

        do {
            try context.save()
        } catch {
            logger.error("Ошибка: \(error.localizedDescription)")
        }
    }
    
    func category(at index: Int) -> TrackerCategory {
        categories[index]
    }
    
    func updateCategory(
        oldTitle: String,
        newTitle: String
    ) {
        let request: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()

        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "title == %@",
            oldTitle
        )

        do {
            guard let category = try context.fetch(request).first else {
                return
            }

            category.title = newTitle
            try context.save()
        } catch {
            logger.error("Не удалось изменить категорию: \(error)")
        }
    }
    
    func deleteCategory(title: String) {
        let request: NSFetchRequest<TrackerCategoryCoreData> =
            TrackerCategoryCoreData.fetchRequest()

        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "title == %@",
            title
        )

        do {
            guard let category = try context.fetch(request).first else {
                return
            }

            context.delete(category)
            try context.save()
        } catch {
            logger.error("Не удалось удалить категорию: \(error)")
        }
    }
    
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        delegate?.didUpdate()
    }
}

