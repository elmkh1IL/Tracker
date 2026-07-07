import UIKit

protocol TrackerCreationViewControllerDelegate: AnyObject {

    func didCreateTracker(_ tracker: Tracker)
}

final class TrackerCreationViewController: UIViewController, ScheduleViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        configureNavigationBar()
        
        setupViews()
        setupConstraints()
        
        cancelButton.addTarget(
            self,
            action: #selector(cancelButtonTapped),
            for: .touchUpInside
        )

        scheduleButton.addTarget(
            self,
            action: #selector(scheduleButtonTapped),
            for: .touchUpInside
        )
        
        createButton.addTarget(
            self,
            action: #selector(createButtonTapped),
            for: .touchUpInside
        )
        
    }
    private var selectedWeekDays: Set<WeekDay> = []
    weak var delegate: TrackerCreationViewControllerDelegate?
    
    private func configureAppearance() {
        view.backgroundColor = .systemBackground
    }

    private func configureNavigationBar() {
        title = "Новая привычка"
    }
    
    private let nameTextField: UITextField = {
        let textField = UITextField()

        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)

        textField.backgroundColor = .systemGray6
        textField.layer.cornerRadius = 16

        textField.translatesAutoresizingMaskIntoConstraints = false

        return textField
    }()
    
    private let optionsView: UIView = {
        let view = UIView()

        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16

        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    private let categoryButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .left
        
        button.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 32
        )

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()

        label.text = "Категория"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let categorySubtitleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let scheduleButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.backgroundColor = .clear

        button.contentHorizontalAlignment = .left
        
        button.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 32
        )
        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private let scheduleSubtitleLabel: UILabel = {
        
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let scheduleTitleLabel: UILabel = {
        let label = UILabel()

        label.text = "Расписание"
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let categoryChevron: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()

    private let scheduleChevron: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .systemGray3
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)

        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 16

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)

        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)

        button.backgroundColor = .systemGray3
        button.layer.cornerRadius = 16

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    @objc
    private func createButtonTapped() {

        guard let name = nameTextField.text,
              !name.isEmpty else {
            return
        }

        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: .systemYellow,
            emoji: ":)",
            schedule: Array(selectedWeekDays)
        )

        delegate?.didCreateTracker(tracker)

        dismiss(animated: true)
    }
    
    private let separatorView: UIView = {
        let view = UIView()

        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    private func updateScheduleSubtitle() {
        
        guard !selectedWeekDays.isEmpty else {
            scheduleSubtitleLabel.isHidden = true
            scheduleSubtitleLabel.text = nil
            return
        }
        
        scheduleSubtitleLabel.isHidden = false
        
        if selectedWeekDays.count == WeekDay.allCases.count {
            scheduleSubtitleLabel.text = "Каждый день"
            return
        }
        
        let sortedDays = selectedWeekDays.sorted {
            $0.rawValue < $1.rawValue
        }
        
        let titles = sortedDays.map { $0.shortTitle }
        
        scheduleSubtitleLabel.text = titles.joined(separator: ", ")
    }
    
    private func setupViews() {
        view.addSubview(nameTextField)
        view.addSubview(optionsView)

        optionsView.addSubview(categoryButton)
        optionsView.addSubview(separatorView)
        optionsView.addSubview(scheduleButton)

        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        optionsView.addSubview(categoryChevron)
        optionsView.addSubview(scheduleChevron)
        
        optionsView.addSubview(categoryTitleLabel)
        optionsView.addSubview(categorySubtitleLabel)

        optionsView.addSubview(scheduleTitleLabel)
        optionsView.addSubview(scheduleSubtitleLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            optionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsView.heightAnchor.constraint(equalToConstant: 150),
            
            categoryButton.topAnchor.constraint(equalTo: optionsView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),
            
            categoryTitleLabel.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
            categoryTitleLabel.topAnchor.constraint(equalTo: optionsView.topAnchor, constant: 16),

            categorySubtitleLabel.leadingAnchor.constraint(equalTo: categoryTitleLabel.leadingAnchor),
            categorySubtitleLabel.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 2),

            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 74),
            
            scheduleTitleLabel.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
            scheduleTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16),

            scheduleSubtitleLabel.leadingAnchor.constraint(equalTo: scheduleTitleLabel.leadingAnchor),
            scheduleSubtitleLabel.topAnchor.constraint(equalTo: scheduleTitleLabel.bottomAnchor, constant: 2),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60),

            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            
            categoryChevron.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor),
            categoryChevron.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor, constant: -16),

            scheduleChevron.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor),
            scheduleChevron.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor, constant: -16),
            
        ])
    }
    
    @objc
    private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc
    private func scheduleButtonTapped() {

        let scheduleViewController = ScheduleViewController()
        
        scheduleViewController.delegate = self

        navigationController?.pushViewController(
            scheduleViewController,
            animated: true
        )
    }
}

extension TrackerCreationViewController {

    func didSelectWeekDays(_ weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays

    updateScheduleSubtitle()

    }
}
