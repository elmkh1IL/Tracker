//
//  StatisticsEmptyStateView.swift
//  Tracker
//
//  Created by el on 06.08.2026.
//

import UIKit

final class StatisticsEmptyStateView: UIView {

    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()

        imageView.image = UIImage(named: "statisticsPlaceholder")

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = String(localized: "statistics.empty")
        label.font = .systemFont(
            ofSize: 12,
            weight: .medium
        )
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                imageView,
                messageLabel
            ]
        )

        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
    }

    // MARK: - Private methods

    private func setupView() {
        backgroundColor = .clear

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(
                equalTo: centerXAnchor
            ),
            stackView.centerYAnchor.constraint(
                equalTo: centerYAnchor
            ),

            imageView.widthAnchor.constraint(
                equalToConstant: 80
            ),
            imageView.heightAnchor.constraint(
                equalToConstant: 80
            )
        ])
    }
}
