import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekDays(_ weekDays: Set<WeekDay>)
}

final class ScheduleViewController: UIViewController {

    weak var delegate: ScheduleViewControllerDelegate?
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        return tableView
    }()
    
    private let weekDays = WeekDay.allCases
    private var selectedWeekDays: Set<WeekDay> = []

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)

        button.backgroundColor = .black
        button.layer.cornerRadius = 16

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = "Расписание"
        tableView.delegate = self
        setupViews()
        setupConstraints()
        
        doneButton.addTarget(
            self,
            action: #selector(doneButtonTapped),
            for: .touchUpInside
        )
    }

    private func setupViews() {

        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        
        tableView.register(
            WeekDayCell.self,
            forCellReuseIdentifier: WeekDayCell.reuseIdentifier
        )
    }
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([

            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),

            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),

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
