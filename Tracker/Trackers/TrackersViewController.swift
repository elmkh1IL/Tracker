import UIKit

final class TrackersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        let completedDays = completedTrackers.filter {
            $0.trackerID == tracker.id
        }.count
        
        let isCompleted = completedTrackers.contains {
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

    private var completedTrackers: [TrackerRecord] = []

    private var currentDate = Date()
    
    private var searchText = ""
    
    private let trackerStore = TrackerStore(context: CoreDataStack.shared.context)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        configureNavigationBar()
        setupViews()
        setupConstraints()
        configureCollectionView()
        trackerStore.delegate = self
        searchBar.delegate = self
        //createTestData()
        updatePlaceholder()
        collectionView.reloadData()
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
    
    private var visibleCategories: [TrackerCategory] {
        trackerStore.trackerCategories.compactMap { category in
            
            let trackers = category.trackers.filter { tracker in
                
                let matchesWeekDay = tracker.schedule.contains(currentWeekDay)
                
                let matchesSearch = searchText.isEmpty ||
                tracker.name.localizedCaseInsensitiveContains(searchText)
                
                return matchesWeekDay && matchesSearch
                
            }

            if trackers.isEmpty {
                return nil
            }

            return TrackerCategory(
                title: category.title,
                trackers: trackers
            )
        }
    }
    
    private func configureAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = Locale(identifier: "ru_RU")

        return picker
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
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
        label.text = "Что будем отслеживать?"
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
        navigationItem.title = "Трекеры"
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
        collectionView.reloadData()
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
        let isEmpty = visibleCategories.isEmpty
        
        placeholderStackView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
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
        
        //return CGSize(width: 167, height: 148)
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
        
        let completedTrackerIndex = completedTrackers.firstIndex { record in record.trackerID == tracker.id &&
            Calendar.current.isDate(record.date, inSameDayAs: currentDate)
        }
        
        if let index = completedTrackerIndex {

            completedTrackers.remove(at: index)

        } else {

            let newRecord = TrackerRecord(
                trackerID: tracker.id,
                date: currentDate
            )

            completedTrackers.append(newRecord)
        }
        collectionView.reloadData()
    }
}

extension TrackersViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.searchText = searchText
        
        collectionView.reloadData()
        
        updatePlaceholder()
    }
}

extension TrackersViewController: TrackerCreationViewControllerDelegate {
    
    func didCreateTracker(
            _ tracker: Tracker,
            category: TrackerCategory
        ) {
            do {
                try trackerStore.addTracker(
                    tracker,
                    categoryTitle: category.title
                )
            } catch {
                print("Не удалось сохранить трекер: \(error)")
            }
        }
}

extension TrackersViewController: TrackerStoreDelegate {

    func didUpdate() {

        collectionView.reloadData()
        updatePlaceholder()
    }
}
