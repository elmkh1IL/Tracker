import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {

    func didUpdate()
}

final class TrackerRecordStore: NSObject {

    weak var delegate: TrackerRecordStoreDelegate?

    private let context: NSManagedObjectContext

    private let fetchedResultsController:
        NSFetchedResultsController<TrackerRecordCoreData>

    init(context: NSManagedObjectContext) {

        self.context = context

        let request: NSFetchRequest<TrackerRecordCoreData> =
            TrackerRecordCoreData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "date",
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

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        delegate?.didUpdate()
    }
}
