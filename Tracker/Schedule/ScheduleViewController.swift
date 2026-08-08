import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekDays(_ weekDays: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController {

    weak var delegate: ScheduleViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        tableView.backgroundColor = .clear

        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )

        tableView.layer.cornerRadius = 16
        tableView.clipsToBounds = true

        return tableView
    }()
    
    private let weekDays = WeekDay.allCases
    private var selectedWeekDays: Set<WeekDay> = []

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle(String(localized: "common.done"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.backgroundColor = .label
        button.layer.cornerRadius = 16

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = String(localized: "tracker.schedule")
        tableView.delegate = self
        navigationItem.hidesBackButton = true
        tableView.separatorStyle = .none
        setupViews()
        setupConstraints()
        
        doneButton.addTarget(
            self,
            action: #selector(doneButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupViews() {

        view.addSubview(containerView)

        containerView.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.sectionHeaderTopPadding = 0
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(
            WeekDayCell.self,
            forCellReuseIdentifier: WeekDayCell.reuseIdentifier
        )
    }
    
    private let containerView: UIView = {
        let view = UIView()

        view.backgroundColor = .trackerSecondaryBackground
        view.layer.cornerRadius = 16

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.heightAnchor.constraint(equalToConstant: 75 * CGFloat(weekDays.count)),
            
            tableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func doneButtonTapped() {
        
        delegate?.didSelectWeekDays(selectedWeekDays)
        
        navigationController?.popViewController(animated: true)
    }
    
}

extension ScheduleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekDays.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: WeekDayCell.reuseIdentifier,
            for: indexPath
        ) as? WeekDayCell else {
            return UITableViewCell()
        }

        cell.titleLabel.text = weekDays[indexPath.row].title
        cell.delegate = self
        
        cell.daySwitch.isOn = selectedWeekDays.contains(
            weekDays[indexPath.row]
        )
        
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        cell.selectionStyle = .none

        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        return 75
    }
}

extension ScheduleViewController: WeekDayCellDelegate {

    func didChangeSwitch(
        on cell: WeekDayCell,
        isOn: Bool
    ) {
        
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        
        let weekDay = weekDays[indexPath.row]
        
        if isOn {
            selectedWeekDays.insert(weekDay)
        } else {
            selectedWeekDays.remove(weekDay)
        }

    }
}
