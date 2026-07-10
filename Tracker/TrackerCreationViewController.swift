import UIKit

protocol TrackerCreationViewControllerDelegate: AnyObject {

    func didCreateTracker(_ tracker: Tracker)
}

final class TrackerCreationViewController: UIViewController {
    
    enum Section: Int, CaseIterable {

        case emoji
        case color

        var title: String {
            switch self {
            case .emoji:
                "Emoji"
            case .color:
                "Цвет"
            }
        }
    }

    private var scheduleTitleCenterConstraint: NSLayoutConstraint!
    private var scheduleTitleTopConstraint: NSLayoutConstraint!
    private var categoryTitleCenterConstraint: NSLayoutConstraint!
    private var categoryTitleTopConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        configureNavigationBar()
        
        setupViews()
        setupConstraints()
        
        updateCreateButtonState()
        
        nameTextField.addTarget(
            self,
            action: #selector(nameTextFieldDidChange),
            for: .editingChanged
        )
        
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
    
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private let emojis = [
        "🙂","😻","🌺","🐶","❤️","😱",
        "😇","😡","🥶","🤔","🙌","🍔",
        "🥦","🏓","🥇","🎸","🏝","😴"
    ]
    
    private let colors: [UIColor] = [
        UIColor(resource: .colorSelection1),
        UIColor(resource: .colorSelection2),
        UIColor(resource: .colorSelection3),
        UIColor(resource: .colorSelection4),
        UIColor(resource: .colorSelection5),
        UIColor(resource: .colorSelection6),
        UIColor(resource: .colorSelection7),
        UIColor(resource: .colorSelection8),
        UIColor(resource: .colorSelection9),
        UIColor(resource: .colorSelection10),
        UIColor(resource: .colorSelection11),
        UIColor(resource: .colorSelection12),
        UIColor(resource: .colorSelection13),
        UIColor(resource: .colorSelection14),
        UIColor(resource: .colorSelection15),
        UIColor(resource: .colorSelection16),
        UIColor(resource: .colorSelection17),
        UIColor(resource: .colorSelection18)
        
    ]
    
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
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always

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
        label.isHidden = true
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
        label.isHidden = true
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
        
        guard
            let emoji = selectedEmoji,
            let color = selectedColor
        else {
            return
        }
        
        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: color,
            emoji: emoji,
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
            
            scheduleTitleTopConstraint.isActive = false
            scheduleTitleCenterConstraint.isActive = true

            return
        }
        
        scheduleSubtitleLabel.isHidden = false
        scheduleTitleCenterConstraint.isActive = false
        scheduleTitleTopConstraint.isActive = true
        
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
    
    private func updateCategorySubtitle() {

        guard let text = categorySubtitleLabel.text,
              !text.isEmpty else {

            categorySubtitleLabel.isHidden = true

            categoryTitleTopConstraint.isActive = false
            categoryTitleCenterConstraint.isActive = true

            return
        }

        categorySubtitleLabel.isHidden = false

        categoryTitleCenterConstraint.isActive = false
        categoryTitleTopConstraint.isActive = true
    }
    
    private func setupViews() {
        view.addSubview(nameTextField)
        view.addSubview(optionsView)
        view.addSubview(collectionView)

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
        
        scheduleTitleCenterConstraint = scheduleTitleLabel.centerYAnchor.constraint(equalTo: scheduleButton.centerYAnchor)
        scheduleTitleTopConstraint = scheduleTitleLabel.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 16)
        scheduleTitleCenterConstraint.isActive = true

        categoryTitleCenterConstraint = categoryTitleLabel.centerYAnchor.constraint(equalTo: categoryButton.centerYAnchor)
        categoryTitleTopConstraint = categoryTitleLabel.topAnchor.constraint(equalTo: optionsView.topAnchor, constant: 16)

        categoryTitleCenterConstraint.isActive = true
        
        NSLayoutConstraint.activate([

            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            optionsView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsView.heightAnchor.constraint(equalToConstant: 150),
            
            collectionView.topAnchor.constraint(equalTo: optionsView.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -24),
            
            categoryButton.topAnchor.constraint(equalTo: optionsView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            categorySubtitleLabel.leadingAnchor.constraint(equalTo: categoryTitleLabel.leadingAnchor),
            categorySubtitleLabel.topAnchor.constraint(equalTo: categoryTitleLabel.bottomAnchor, constant: 2),
            categoryTitleLabel.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),

            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),

            scheduleButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 74),
            
            scheduleTitleLabel.leadingAnchor.constraint(equalTo: optionsView.leadingAnchor, constant: 16),
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
    
    private lazy var collectionView: UICollectionView = {

        let layout = UICollectionViewFlowLayout()

        let collection = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collection.backgroundColor = .clear
        collection.translatesAutoresizingMaskIntoConstraints = false

        collection.delegate = self
        collection.dataSource = self

        collection.register(
            EmojiColorCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiColorCollectionViewCell.reuseIdentifier
        )

        collection.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )

        return collection
    }()
    
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
    
    @objc
    private func nameTextFieldDidChange() {
        updateCreateButtonState()
    }
    
    private func updateCreateButtonState() {
        let hasName = !(nameTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ?? true)

        let hasSchedule = !selectedWeekDays.isEmpty
        let hasEmoji = selectedEmoji != nil
        let hasColor = selectedColor != nil

        let isEnabled =
            hasName &&
            hasSchedule &&
            hasEmoji &&
            hasColor

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .black : .systemGray3
    }
    
}

extension TrackerCreationViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath
        ) {

            switch Section(rawValue: indexPath.section)! {

            case .emoji:
                selectedEmoji = emojis[indexPath.item]

            case .color:
                selectedColor = colors[indexPath.item]
            }

            collectionView.reloadData()
            updateCreateButtonState()
        }
}

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 52, height: 52)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        5
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 24,
            right: 0
        )
    }
}

extension TrackerCreationViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        switch Section(rawValue: section)! {
        case .emoji:
            return emojis.count

        case .color:
            return colors.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: EmojiColorCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? EmojiColorCollectionViewCell else {
            return UICollectionViewCell()
        }

        switch Section(rawValue: indexPath.section)! {

        case .emoji:

            let emoji = emojis[indexPath.item]

            cell.configure(with: emoji)

            cell.setSelected(emoji == selectedEmoji)

        case .color:

            let color = colors[indexPath.item]

            cell.configure(with: color)

            cell.setSelected(color == selectedColor)
        }

        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {

        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
            for: indexPath
        ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }

        header.titleLabel.text = Section(rawValue: indexPath.section)?.title

        return header
    }
}

extension TrackerCreationViewController: ScheduleViewControllerDelegate {

    func didSelectWeekDays(_ weekDays: Set<WeekDay>) {
        selectedWeekDays = weekDays

        updateScheduleSubtitle()
        updateCreateButtonState()
    }
}
