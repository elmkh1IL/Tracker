import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {

    func didUpdate()
}

final class TrackerCategoryStore: NSObject {

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
            print(error)
        }
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        delegate?.didUpdate()
    }
}
