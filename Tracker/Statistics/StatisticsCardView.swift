//
//  StatisticsCardView.swift
//  Tracker
//
//  Created by el on 06.08.2026.
//

import UIKit

final class StatisticsCardView: UIView {

    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 34,
            weight: .bold)
        
        label.textColor = .label
        label.text = "0"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(
            ofSize: 12,
            weight: .medium)
        
        label.textColor = .label
        label.text = String(localized: "statistics.completed")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let gradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
        setupGradientBorder()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setupView()
        setupGradientBorder()
        setupConstraints()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds

        let lineWidth = borderMaskLayer.lineWidth
        let inset = lineWidth / 2

        let borderRect = bounds.insetBy(
            dx: inset,
            dy: inset)

        borderMaskLayer.path = UIBezierPath(
            roundedRect: borderRect,
            cornerRadius: 16 - inset
        ).cgPath
    }

    func configure(count: Int) {
        countLabel.text = String(count)
    }

    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16

        addSubview(countLabel)
        addSubview(descriptionLabel)
    }

    private func setupGradientBorder() {
        gradientLayer.colors = [
            UIColor.systemRed.cgColor,
            UIColor.systemGreen.cgColor,
            UIColor.systemBlue.cgColor
        ]

        gradientLayer.startPoint = CGPoint(
            x: 0,
            y: 0.5
        )

        gradientLayer.endPoint = CGPoint(
            x: 1,
            y: 0.5
        )

        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderMaskLayer.lineWidth = 1.5

        gradientLayer.mask = borderMaskLayer

        layer.insertSublayer(
            gradientLayer,
            at: 0)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            countLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),

            descriptionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            descriptionLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
