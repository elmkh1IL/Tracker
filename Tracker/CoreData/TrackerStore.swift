import CoreData
import UIKit

protocol TrackerStoreDelegate: AnyObject {
    
    func didUpdate()
}

final class TrackerStore: NSObject {

    weak var delegate: TrackerStoreDelegate?

    private let context: NSManagedObjectContext

    private let fetchedResultsController:
        NSFetchedResultsController<TrackerCoreData>
    
    var trackers: [Tracker] {
        fetchedResultsController.fetchedObjects?
            .compactMap { makeTracker(from: $0) } ?? []
    }
    
    var trackerCategories: [TrackerCategory] {
        guard let objects = fetchedResultsController.fetchedObjects else {
            return []
        }

        var groupedTrackers: [String: [Tracker]] = [:]

        for object in objects {
            guard
                let tracker = makeTracker(from: object),
                let categoryTitle = object.category?.title,
                !categoryTitle.isEmpty
            else {
                continue
            }

            groupedTrackers[categoryTitle, default: []].append(tracker)
        }

        return groupedTrackers.keys
            .sorted()
            .map { title in
                TrackerCategory(
                    title: title,
                    trackers: groupedTrackers[title] ?? []
                )
            }
    }
    
    init(context: NSManagedObjectContext) {

        self.context = context

        let request: NSFetchRequest<TrackerCoreData> =
            TrackerCoreData.fetchRequest()

        request.sortDescriptors = [
            NSSortDescriptor(
                key: "name",
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
    
    func addTracker(_ tracker: Tracker, categoryTitle: String) throws {

        let trackerCoreData = TrackerCoreData(context: context)

        trackerCoreData.id = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.color = tracker.color
        trackerCoreData.schedule = tracker.schedule.map { $0.rawValue } as NSObject

        let categoryRequest = TrackerCategoryCoreData.fetchRequest()

        categoryRequest.fetchLimit = 1
        categoryRequest.predicate = NSPredicate(
            format: "title == %@",
            categoryTitle
        )

        let category: TrackerCategoryCoreData

        if let existingCategory = try context.fetch(categoryRequest).first {

            category = existingCategory

        } else {

            category = TrackerCategoryCoreData(context: context)
            category.title = categoryTitle
        }

        trackerCoreData.category = category

        try context.save()
    }
    
    private func makeTracker(
        from object: TrackerCoreData
    ) -> Tracker? {
        guard
            let id = object.id,
            let name = object.name,
            let emoji = object.emoji,
            let color = object.color as? UIColor,
            let scheduleArray = object.schedule as? [Int]
        else {
            return nil
        }

        let schedule = scheduleArray.compactMap {
            WeekDay(rawValue: $0)
        }

        return Tracker(
            id: id,
            name: name,
            color: color,
            emoji: emoji,
            schedule: schedule
        )
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>
    ) {

        delegate?.didUpdate()
    }
}
