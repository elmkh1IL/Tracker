//
//  CategoryTableViewCell.swift
//  Tracker
//
//  Created by el on 29.07.2026.
//

import UIKit

final class CategoryTableViewCell: UITableViewCell {

    static let reuseIdentifier = "CategoryTableViewCell"

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 17)
        label.textColor = .label

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor(resource: .blue)

        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    func configure(
        with category: TrackerCategory,
        isSelected: Bool
    ) {
        
        titleLabel.text = category.title
        
        checkmarkImageView.isHidden = !isSelected
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {

        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)

        configureCell()
        setupViews()
        setupConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private let separatorView: UIView = {
        let view = UIView()

        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()
    
    func setSeparatorHidden(_ hidden: Bool) {
        separatorView.isHidden = hidden
    }
}

private extension CategoryTableViewCell {
    
    func configureCell() {
        contentView.backgroundColor = .trackerSecondaryBackground
        selectionStyle = .none
        
        separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
    }
    
    func setupViews() {
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)
        contentView.addSubview(separatorView)
    }
    
    func setupConstraints() {
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
