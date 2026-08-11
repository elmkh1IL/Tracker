import UIKit
import OSLog

final class TrackersViewController: UIViewController, UICollectionViewDataSource {
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Tracker",
        category: "TrackersViewController"
    )
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let completedDays = trackerRecordStore.records.filter {
            $0.trackerID == tracker.id
        }.count
        
        let isCompleted = trackerRecordStore.records.contains {
            $0.trackerID == tracker.id &&
            Calendar.current.isDate($0.date, inSameDayAs: currentDate)
        }
        
        cell.configure(
            with: tracker,
            isCompleted: isCompleted,
            completedDays: completedDays
        )
        cell.delegate = self
        return cell
    }
    
    private let trackerRecordStore = TrackerRecordStore(
        context: CoreDataStack.shared.context
    )
    
    private var currentDate = Date()
    
    private var searchText = ""
    
    private let trackerStore = TrackerStore(context: CoreDataStack.shared.context)
    
    private var currentFilter: TrackerFilter = .all
    
    private let analyticsService = AnalyticsService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        configureNavigationBar()
        setupViews()
        setupConstraints()
        configureCollectionView()
        setupFiltersButton()
        
        trackerStore.delegate = self
        trackerRecordStore.delegate = self
        searchBar.delegate = self
        
        refreshTrackers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        analyticsService.report(
            event: .open,
            screen: .main
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        analyticsService.report(
            event: .close,
            screen: .main
        )
    }
    
    private var currentWeekDay: WeekDay {
        let weekDay = Calendar.current.component(.weekday, from: currentDate)
        
        switch weekDay {
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return .sunday
        }
    }
    
    private var categoriesForSelectedDay: [TrackerCategory] {
        trackerStore.trackerCategories.compactMap { category in

            let trackersForDay = category.trackers.filter { tracker in
                tracker.schedule.contains(currentWeekDay)
            }

            guard !trackersForDay.isEmpty else {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: trackersForDay
            )
        }
    }
    
    private var categoriesMatchingSearch: [TrackerCategory] {
        categoriesForSelectedDay.compactMap { category in

            let matchingTrackers = category.trackers.filter { tracker in
                searchText.isEmpty ||
                tracker.name.localizedCaseInsensitiveContains(searchText)
            }

            guard !matchingTrackers.isEmpty else {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: matchingTrackers
            )
        }
    }
    
    private var visibleCategories: [TrackerCategory] {
        applyCurrentFilter(
            to: categoriesMatchingSearch
        )
    }
    
    private func isTrackerCompleted(_ tracker: Tracker, on date: Date) -> Bool {
        trackerRecordStore.records.contains { record in
            record.trackerID == tracker.id
            && Calendar.current.isDate(
                record.date,
                inSameDayAs: date
            )
        }
    }
    
    private func applyCurrentFilter(to categories: [TrackerCategory]) -> [TrackerCategory] {
        categories.compactMap { category in

            let filteredTrackers: [Tracker]

            switch currentFilter {
            case .all, .today:
                filteredTrackers = category.trackers

            case .completed:
                filteredTrackers = category.trackers.filter { tracker in
                    isTrackerCompleted(
                        tracker,
                        on: currentDate
                    )
                }

            case .uncompleted:
                filteredTrackers = category.trackers.filter { tracker in
                    !isTrackerCompleted(
                        tracker,
                        on: currentDate
                    )
                }
            }

            guard !filteredTrackers.isEmpty else {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: filteredTrackers
            )
        }
    }
    
    private func updateFiltersButtonVisibility() {
        let hasTrackersForSelectedDay =
            categoriesForSelectedDay.contains { category in
                !category.trackers.isEmpty
            }

        filtersButton.isHidden =
            !hasTrackersForSelectedDay

        updateCollectionViewInsets()
    }
    
    private func updateCollectionViewInsets() {
        let bottomInset: CGFloat =
            filtersButton.isHidden
            ? 16
            : 90

        var contentInset = collectionView.contentInset
        contentInset.bottom = bottomInset
        collectionView.contentInset = contentInset

        var indicatorInsets =
            collectionView.verticalScrollIndicatorInsets

        indicatorInsets.bottom = bottomInset

        collectionView.verticalScrollIndicatorInsets =
            indicatorInsets

        collectionView.alwaysBounceVertical = true
    }
    
    private func refreshTrackers() {
        collectionView.reloadData()
        updateFiltersButtonVisibility()
        updatePlaceholder()
    }
    
    private func configureAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = .current
        picker.tintColor = .label
        
        return picker
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = String(localized: "trackers.search.placeholder")
        searchBar.searchTextField.backgroundColor = .systemGray6
        searchBar.backgroundImage = UIImage()
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .placeholderStar)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "trackers.placeholder.empty")
        label.font = .systemFont(ofSize: 12, weight:  .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let placeholderStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func setupViews() {
        view.addSubview(searchBar)
        view.addSubview(collectionView)
        view.addSubview(placeholderStackView)
        
        placeholderStackView.addArrangedSubview(placeholderImageView)
        placeholderStackView.addArrangedSubview(placeholderLabel)
    }
    
    private func configureNavigationBar() {
        navigationItem.title = String(localized: "trackers.title")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addTracker))
        
        datePicker.addTarget(
            self,
            action: #selector(dateChanged),
            for: .valueChanged
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            customView: datePicker
        )
    }
    
    @objc
    private func addTracker() {
        
        analyticsService.report(
                event: .click,
                screen: .main,
                item: .addTrack
            )

        let creationViewController = TrackerCreationViewController()
        creationViewController.delegate = self
        
        let navigationController = UINavigationController(
            rootViewController: creationViewController
        )
        
        present(navigationController, animated: true)
    }
    
    @objc
    private func dateChanged() {
        currentDate = datePicker.date
        refreshTrackers()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            placeholderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private func configureCollectionView() {
        
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCell")
        
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = visibleCategories[indexPath.section].title
        
        return header
    }
    
    private func updatePlaceholder() {
        let hasTrackersForSelectedDay =
            categoriesForSelectedDay.contains { category in
                !category.trackers.isEmpty
            }

        let hasVisibleTrackers =
            visibleCategories.contains { category in
                !category.trackers.isEmpty
            }

        let isSearchActive =
                !searchText
                    .trimmingCharacters(
                        in: .whitespacesAndNewlines
                    )
                    .isEmpty
        
        if hasVisibleTrackers {
            placeholderStackView.isHidden = true
            return
        }

        placeholderStackView.isHidden = false

        if isSearchActive || hasTrackersForSelectedDay {
                placeholderImageView.image = UIImage(
                    resource: .placeholderError
                )

            placeholderLabel.text = String(localized: "trackers.placeholder.notFound")
        } else {
            placeholderImageView.image = UIImage(
                resource: .placeholderStar
            )

            placeholderLabel.text = String(localized: "trackers.placeholder.empty")
        }
    }
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)

        button.translatesAutoresizingMaskIntoConstraints = false

        button.setTitle(
            String(localized: "trackers.filters"),
            for: .normal
        )

        button.setTitleColor(
            .white,
            for: .normal
        )

        button.titleLabel?.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )

        button.backgroundColor = UIColor(resource: .blue)
        button.layer.cornerRadius = 16

        button.addTarget(
            self,
            action: #selector(filtersButtonTapped),
            for: .touchUpInside
        )

        button.isHidden = true

        return button
    }()
    
    private func setupFiltersButton() {
        view.addSubview(filtersButton)

        NSLayoutConstraint.activate([
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),

            filtersButton.widthAnchor.constraint(equalToConstant: 114),

            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        view.bringSubviewToFront(filtersButton)

        collectionView.alwaysBounceVertical = true
    }
    
    @objc
    private func filtersButtonTapped() {
        
        analyticsService.report(
               event: .click,
               screen: .main,
               item: .filter
           )
        
        let filtersViewController = FiltersViewController(
            selectedFilter: currentFilter
        )

        filtersViewController.delegate = self

        let navigationController = UINavigationController(
            rootViewController: filtersViewController
        )

        navigationController.modalPresentationStyle = .pageSheet

        present(
            navigationController,
            animated: true
        )
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        
        let spacing: CGFloat = 9
        let sideInset: CGFloat = 16

        let width = (collectionView.bounds.width - sideInset * 2 - spacing) / 2

        return CGSize(
            width: width,
            height: 148
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {

        CGSize(width: collectionView.frame.width, height: 46)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        return 16
    }
    
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {

    func didTapCompleteButton(on cell: TrackerCollectionViewCell) {
        
        analyticsService.report(
                event: .click,
                screen: .main,
                item: .track
            )
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        let calendar = Calendar.current
        
        if calendar.compare(
            currentDate,
            to: Date(),
            toGranularity: .day
        ) == .orderedDescending {
            return
        }
        
        let isCompleted = trackerRecordStore.records.contains {
            $0.trackerID == tracker.id &&
            Calendar.current.isDate(
                $0.date,
                inSameDayAs: currentDate
            )
        }
        
        if isCompleted {
            trackerRecordStore.deleteRecord(
                trackerID: tracker.id,
                date: currentDate
            )
        } else {
            trackerRecordStore.addRecord(
                trackerID: tracker.id,
                date: currentDate
            )
        }
    }
}

extension TrackersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        
        refreshTrackers()
    }
}

extension TrackersViewController: TrackerCreationViewControllerDelegate {
    
    func didCreateTracker(_ tracker: Tracker, category: TrackerCategory) {
            do {
                try trackerStore.addTracker(
                    tracker,
                    categoryTitle: category.title
                )
            } catch {
                logger.error("Не удалось сохранить трекер: \(error.localizedDescription)")
            }
        }
    
    func didUpdateTracker(_ tracker: Tracker, category: TrackerCategory) {
        do {
            try trackerStore.updateTracker(
                tracker,
                categoryTitle: category.title
            )
        } catch {
            logger.error(
                "Не удалось обновить трекер: \(error.localizedDescription)"
            )
        }
    }
}

extension TrackersViewController: TrackerStoreDelegate, TrackerRecordStoreDelegate {

    func didUpdate() {

        refreshTrackers()
    }
}

extension TrackersViewController {

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {

        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        let completedDays = trackerRecordStore.records.filter {
            $0.trackerID == tracker.id
        }.count

        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: nil
        ) { [weak self] _ in

            let editAction = UIAction(
                title: String(localized: "common.edit")
            ) { [weak self] _ in
                
                guard let self else {
                        return
                    }
                
                self.analyticsService.report(
                    event: .click,
                    screen: .main,
                    item: .edit
                )
                
                self.editTracker(
                    tracker,
                    categoryTitle: category.title,
                    completedDays: completedDays
                )
            }

            let deleteAction = UIAction(
                title: String(localized: "common.delete"),
                attributes: .destructive
            ) { [weak self] _ in
                guard let self else {
                        return
                    }
                
                self.analyticsService.report(
                        event: .click,
                        screen: .main,
                        item: .delete
                    )
                
                self.showDeleteConfirmation(
                    for: tracker
                )
            }

            return UIMenu(
                children: [
                    editAction,
                    deleteAction
                ]
            )
        }
    }

    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard
            let indexPath =
                configuration.identifier as? NSIndexPath,
            let cell = collectionView.cellForItem(
                at: indexPath as IndexPath
            ) as? TrackerCollectionViewCell
        else {
            return nil
        }

        return cell.makeContextMenuPreview()
    }

    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {

        guard
            let indexPath =
                configuration.identifier as? NSIndexPath,
            let cell = collectionView.cellForItem(
                at: indexPath as IndexPath
            ) as? TrackerCollectionViewCell
        else {
            return nil
        }

        return cell.makeContextMenuPreview()
    }
}

private extension TrackersViewController {

    func editTracker(_ tracker: Tracker, categoryTitle: String, completedDays: Int) {
        let creationViewController =
            TrackerCreationViewController(
                mode: .edit(
                    tracker: tracker,
                    categoryTitle: categoryTitle,
                    completedDays: completedDays
                )
            )

        creationViewController.delegate = self

        let navigationController = UINavigationController(
            rootViewController: creationViewController
        )

        present(
            navigationController,
            animated: true
        )
    }
    
    func showDeleteConfirmation(
        for tracker: Tracker
    ) {
        let alert = UIAlertController(
            title: nil,
            message: String(localized: "tracker.delete.confirmation"),
            preferredStyle: .actionSheet
        )

        let deleteAction = UIAlertAction(
            title: String(localized: "common.delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.deleteTracker(tracker)
        }

        let cancelAction = UIAlertAction(
            title: String(localized: "common.cancel"),
            style: .cancel
        )

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        present(
            alert,
            animated: true
        )
    }

    func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            logger.error(
                "Не удалось удалить трекер: \(error.localizedDescription)"
            )
        }
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {

    func didSelectFilter(_ filter: TrackerFilter) {
        switch filter {
        case .all:
            currentFilter = .all

        case .today:
            currentDate = Date()
            currentFilter = .all

            datePicker.setDate(
                currentDate,
                animated: true
            )

        case .completed:
            currentFilter = .completed

        case .uncompleted:
            currentFilter = .uncompleted
        }

        refreshTrackers()
    }
}
