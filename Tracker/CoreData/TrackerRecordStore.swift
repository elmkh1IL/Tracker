import CoreData
import OSLog

protocol TrackerRecordStoreDelegate: AnyObject {

    func didUpdate()
}

final class TrackerRecordStore: NSObject {
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Tracker",
        category: "TrackerRecordStore"
    )

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
            logger.error("Ошибка: \(error.localizedDescription)")
        }
    }
    
    var records: [TrackerRecord] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }

        return objects.compactMap { object in
            guard
                let trackerID = object.tracker?.id,
                let date = object.date
            else {
                return nil
            }

            return TrackerRecord(
                trackerID: trackerID,
                date: date
            )
        }
    }
    
    func addRecord(
        trackerID: UUID,
        date: Date
    ) {
        let trackerRequest: NSFetchRequest<TrackerCoreData> =
            TrackerCoreData.fetchRequest()

        trackerRequest.fetchLimit = 1
        trackerRequest.predicate = NSPredicate(
            format: "id == %@",
            trackerID as NSUUID
        )

        do {
            guard let trackerCoreData =
                    try context.fetch(trackerRequest).first else {
                logger.error("Не найден трекер с id: \(trackerID)")
                return
            }

            let record = TrackerRecordCoreData(context: context)

            record.id = UUID()
            record.date = date
            record.tracker = trackerCoreData

            try context.save()
        } catch {
            logger.error("Не удалось сохранить запись: \(error)")
        }
    }
    
    func deleteRecord(
        trackerID: UUID,
        date: Date
    ) {
        let request: NSFetchRequest<TrackerRecordCoreData> =
            TrackerRecordCoreData.fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        guard let endOfDay = calendar.date(
            byAdding: .day,
            value: 1,
            to: startOfDay
        ) else {
            return
        }

        request.fetchLimit = 1
        
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as NSUUID,
            startOfDay as NSDate,
            endOfDay as NSDate
        )

        do {
            guard let record = try context.fetch(request).first else {
                return
            }

            context.delete(record)
            try context.save()
        } catch {
            logger.error("Не удалось удалить запись: \(error)")
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        delegate?.didUpdate()
    }
}
