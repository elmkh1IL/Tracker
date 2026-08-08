import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func didTapCompleteButton(on cell: TrackerCollectionViewCell)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "TrackerCell"
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(cardView)
        
        cardView.addSubview(emojiLabel)
        cardView.addSubview(titleLabel)
        
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)
        
        completeButton.addTarget(
            self,
            action: #selector(completeButtonTapped),
            for: .touchUpInside
        )
        
        cardView.clipsToBounds = true
        
        setupConstraints()
        
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    private let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white

        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)

        label.textAlignment = .center
        label.backgroundColor = UIColor.white.withAlphaComponent(0.3)

        label.layer.cornerRadius = 12
        label.clipsToBounds = true

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let daysLabel: UILabel = {
        let label = UILabel()

        label.font = .systemFont(ofSize: 12)

        label.translatesAutoresizingMaskIntoConstraints = false

        return label
    }()
    
    private let completeButton: UIButton = {
        let button = UIButton(type: .system)

        button.setImage(
            UIImage(systemName: "plus"),
            for: .normal
        )

        button.tintColor = .systemBackground
        button.backgroundColor = .systemGreen

        button.layer.cornerRadius = 17

        button.translatesAutoresizingMaskIntoConstraints = false

        return button
    }()
    
    @objc
    private func completeButtonTapped() {
        delegate?.didTapCompleteButton(on: self)
    }
    
    private func updateButton() {

        let imageName = isCompleted ? "checkmark" : "plus"

        completeButton.setImage(
            UIImage(systemName: imageName),
            for: .normal
        )
    }
    
    private func updateDaysLabel() {
        
        let format = String(localized: "tracker.days.count")
        
        daysLabel.text = String.localizedStringWithFormat(format, completedDays)
    }
    
    private var isCompleted = false
    private var completedDays = 0
    
    func configure(
        with tracker: Tracker,
        isCompleted: Bool,
        completedDays: Int
    ) {
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.name
        
        cardView.backgroundColor = tracker.color
        completeButton.backgroundColor = tracker.color

        self.isCompleted = isCompleted
        self.completedDays = completedDays

        updateButton()
        updateDaysLabel()
    }
    
    func makeContextMenuPreview() -> UITargetedPreview {
        layoutIfNeeded()

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        parameters.visiblePath = UIBezierPath(
            roundedRect: cardView.bounds,
            cornerRadius: cardView.layer.cornerRadius
        )

        return UITargetedPreview(
            view: cardView,
            parameters: parameters
        )
    }
    
    private func setupConstraints() {

        NSLayoutConstraint.activate([
            
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),

            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            completeButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
}
