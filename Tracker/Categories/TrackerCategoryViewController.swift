import UIKit

protocol TrackerCategoryViewControllerDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

final class TrackerCategoryViewController: UIViewController {
    
    weak var delegate: TrackerCategoryViewControllerDelegate?
    
    private let store: TrackerCategoryStore
    private let viewModel: TrackerCategoryViewModel
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private lazy var longPressGestureRecognizer =
    UILongPressGestureRecognizer(
        target: self,
        action: #selector(handleLongPress)
    )
    
    init(
        store: TrackerCategoryStore,
        viewModel: TrackerCategoryViewModel
    ) {
        self.store = store
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        setupViews()
        setupConstraints()
        bind()
    
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        updateTableViewHeight()
    }
    
    private func configureAppearance() {
        view.backgroundColor = .systemBackground
        title = String(localized: "tracker.category")
        navigationItem.hidesBackButton = true
    }
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        
        tableView.backgroundColor = .trackerSecondaryBackground
        
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        
        tableView.sectionHeaderTopPadding = 0
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        
        
        return tableView
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setTitle(String(localized: "category.add"), for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        
        button.backgroundColor = .label
        button.layer.cornerRadius = 16
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let placeholderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        
        imageView.image = UIImage(resource: .placeholderStar)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let placeholderLabel: UILabel = {
        
        let label = UILabel()
        
        label.text = String(localized: "category.placeholder")
        label.numberOfLines = 2
        label.textAlignment = .center
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private func setupViews() {
        
        tableView.register(
            CategoryTableViewCell.self,
            forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier
        )
        
        tableView.delegate = self
        tableView.dataSource = self
        
        addButton.addTarget(
            self,
            action: #selector(addButtonTapped),
            for: .touchUpInside
        )
        
        tableView.contentInset = .zero
        tableView.layoutMargins = .zero
        
        view.addSubview(tableView)
        view.addSubview(addButton)
        view.addSubview(placeholderView)
        tableView.addGestureRecognizer(longPressGestureRecognizer)
        
        placeholderView.addSubview(placeholderImageView)
        placeholderView.addSubview(placeholderLabel)
        
    }
    
    private func setupConstraints() {
        
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        
        tableViewHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            heightConstraint,
            
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderImageView.topAnchor.constraint(equalTo: placeholderView.topAnchor),
            placeholderImageView.centerXAnchor.constraint(equalTo: placeholderView.centerXAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: placeholderView.leadingAnchor),
            placeholderLabel.trailingAnchor.constraint(equalTo: placeholderView.trailingAnchor),
            placeholderLabel.bottomAnchor.constraint(equalTo: placeholderView.bottomAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updateTableViewHeight() {
        let rowHeight: CGFloat = 75

        let contentHeight =
            CGFloat(viewModel.numberOfCategories) * rowHeight

        let maximumHeight =
            addButton.frame.minY -
            tableView.frame.minY -
            16

        guard maximumHeight > 0 else {
            return
        }

        tableViewHeightConstraint?.constant = min(
            contentHeight,
            maximumHeight
        )

        tableView.isScrollEnabled =
            contentHeight > maximumHeight
    }
    
    private func bind() {
        
        viewModel.onCategoriesChanged = { [weak self] in
            self?.updateState()
        }
        
        viewModel.onCategorySelected = { [weak self] category in
            self?.delegate?.didSelectCategory(category)
            self?.navigationController?.popViewController(animated: true)
        }
        
        updateState()
    }
    
    private func updateState() {
        
        let isEmpty = viewModel.isEmpty
        
        placeholderView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        
        tableView.reloadData()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    @objc
    private func addButtonTapped() {
        
        let newCategoryViewModel = NewCategoryViewModel(
            store: store
        )
        
        let viewController = NewCategoryViewController(
            viewModel: newCategoryViewModel
        )
    
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    @objc
    private func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        guard gestureRecognizer.state == .began else {
            return
        }
        
        let point = gestureRecognizer.location(in: tableView)
        
        guard let indexPath = tableView.indexPathForRow(at: point) else {
            return
        }
        
        showCategoryActions(for: indexPath)
    }
    
    private func showCategoryActions(for indexPath: IndexPath) {
        let category = viewModel.category(at: indexPath.row)
        
        let alert = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let editAction = UIAlertAction(
            title: String(localized: "common.edit"),
            style: .default
        ) { [weak self] _ in
            self?.showEditCategory(category)
        }
        
        let deleteAction = UIAlertAction(
            title: String(localized: "common.delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.showDeleteConfirmation(for: category)
        }
        
        let cancelAction = UIAlertAction(
            title: String(localized: "common.cancel"),
            style: .cancel
        )
        
        alert.addAction(editAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        configurePopover(for: alert)
        present(alert, animated: true)
    }
    
    private func configurePopover(
        for alert: UIAlertController
    ) {
        guard let popover = alert.popoverPresentationController else {
            return
        }

        popover.sourceView = tableView
        popover.sourceRect = CGRect(
            x: tableView.bounds.midX,
            y: tableView.bounds.midY,
            width: 0,
            height: 0
        )
        popover.permittedArrowDirections = []
    }
    
    private func showEditCategory(_ category: TrackerCategory) {
        let editViewModel = NewCategoryViewModel(
            store: store,
            mode: .edit(originalTitle: category.title)
        )
        
        let viewController = NewCategoryViewController(
            viewModel: editViewModel,
            initialTitle: category.title
        )
        
        navigationController?.pushViewController(
            viewController,
            animated: true
        )
    }
    
    private func showDeleteConfirmation(for category: TrackerCategory) {
        let alert = UIAlertController(
            title: nil,
            message: String(localized: "category.delete.confirmation"),
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: String(localized: "common.delete"),
            style: .destructive
        ) { [weak self] _ in
            self?.viewModel.deleteCategory(category)
        }
        
        let cancelAction = UIAlertAction(
            title: String(localized: "common.cancel"),
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        configurePopover(for: alert)
        present(alert, animated: true)
    }
}

extension TrackerCategoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        viewModel.numberOfCategories
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryTableViewCell else {
            return UITableViewCell()
        }

        let category = viewModel.category(at: indexPath.row)

        cell.configure(
            with: category,
            isSelected: viewModel.isCategorySelected(at: indexPath.row)
        )

        cell.setSeparatorHidden(
            indexPath.row == viewModel.numberOfCategories - 1
        )
        
        return cell
    }
}

extension TrackerCategoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        viewModel.selectCategory(at: indexPath.row)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        75
    }
}
