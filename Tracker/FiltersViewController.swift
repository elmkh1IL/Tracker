//
//  FiltersViewController.swift
//  Tracker
//
//  Created by el on 05.08.2026.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func didSelectFilter(_ filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    
    weak var delegate: FiltersViewControllerDelegate?
    
    private let selectedFilter: TrackerFilter
    
    private let filters = TrackerFilter.allCases
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(
            frame: .zero,
            style: .plain
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isScrollEnabled = false
        tableView.tableFooterView = UIView()
        
        return tableView
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        return view
    }()
    
    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        
        super.init(
            nibName: nil,
            bundle: nil
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureAppearance()
        setupLayout()
    }
    
    private func configureAppearance() {
        view.backgroundColor = .systemBackground
        
        title = "Фильтры"
    }
    
    private func setupLayout() {
        view.addSubview(containerView)
        containerView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor,
                constant: 24
            ),
            
            containerView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: 16
            ),
            
            containerView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -16
            ),
            
            containerView.heightAnchor.constraint(
                equalToConstant: 300
            ),
            
            tableView.topAnchor.constraint(
                equalTo: containerView.topAnchor
            ),
            
            tableView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor
            ),
            
            tableView.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor
            ),
            
            tableView.bottomAnchor.constraint(
                equalTo: containerView.bottomAnchor
            )
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "FilterCell"

        let cell =
            tableView.dequeueReusableCell(
                withIdentifier: reuseIdentifier
            )
            ?? UITableViewCell(
                style: .default,
                reuseIdentifier: reuseIdentifier
            )

        let filter = filters[indexPath.row]

        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(
            ofSize: 17,
            weight: .regular
        )

        cell.selectionStyle = .none
        cell.tintColor = UIColor(resource: .blue)
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear
        
        switch filter {
        case .completed, .uncompleted:
            cell.accessoryType =
                filter == selectedFilter
                ? .checkmark
                : .none

        case .all, .today:
            cell.accessoryType = .none
        }

        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedFilter = filters[indexPath.row]

        delegate?.didSelectFilter(selectedFilter)

        navigationController?.dismiss(
                animated: true
            )
    }
}
