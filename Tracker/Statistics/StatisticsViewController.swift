import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStore
    
    private let statisticsCardView: StatisticsCardView = {
            let view = StatisticsCardView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

        private let emptyStateView: StatisticsEmptyStateView = {
            let view = StatisticsEmptyStateView()
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()

    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        
        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    convenience init() {
            let trackerRecordStore = TrackerRecordStore(
                context: CoreDataStack.shared.context
            )

            self.init(
                trackerRecordStore: trackerRecordStore
            )
        }

        required init?(coder: NSCoder) {
            fatalError(
                "init(coder:) has not been implemented"
            )
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupNavigationBar()
        setupConstraints()
        setupStore()
        view.backgroundColor = .systemBackground
        updateStatistics()
    }
    
    private func setupView() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(statisticsCardView)
        view.addSubview(emptyStateView)
    }
    
    private func setupNavigationBar() {
        title = String(localized: "statistics.title")
        
        navigationItem.largeTitleDisplayMode = .always
        
        navigationController?
            .navigationBar
            .prefersLargeTitles = true
    }
    
    private func setupStore() {
        trackerRecordStore.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
                statisticsCardView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor,
                    constant: 60
                ),
                statisticsCardView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor,
                    constant: 16
                ),
                statisticsCardView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor,
                    constant: -16
                ),
                statisticsCardView.heightAnchor.constraint(
                    equalToConstant: 90
                ),

                emptyStateView.topAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.topAnchor
                ),
                emptyStateView.leadingAnchor.constraint(
                    equalTo: view.leadingAnchor
                ),
                emptyStateView.trailingAnchor.constraint(
                    equalTo: view.trailingAnchor
                ),
                emptyStateView.bottomAnchor.constraint(
                    equalTo: view.safeAreaLayoutGuide.bottomAnchor
                )
            ])
        }
    
    private func updateStatistics() {
           let completedTrackersCount =
               trackerRecordStore.records.count

           statisticsCardView.configure(
               count: completedTrackersCount
           )

           let hasCompletedTrackers =
               completedTrackersCount > 0

           statisticsCardView.isHidden =
               !hasCompletedTrackers

           emptyStateView.isHidden =
               hasCompletedTrackers
       }
   }

extension StatisticsViewController:
    TrackerRecordStoreDelegate {

    func didUpdate() {
        DispatchQueue.main.async { [weak self] in
            self?.updateStatistics()
        }
    }
}
