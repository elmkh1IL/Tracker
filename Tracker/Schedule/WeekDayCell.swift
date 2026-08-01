import UIKit

protocol WeekDayCellDelegate: AnyObject {
    func didChangeSwitch(
        on cell: WeekDayCell,
        isOn: Bool
    )
}

final class WeekDayCell: UITableViewCell {

    static let reuseIdentifier = "WeekDayCell"
    weak var delegate: WeekDayCellDelegate?

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    let daySwitch: UISwitch = {
        let switchView = UISwitch()
        switchView.onTintColor = .systemBlue
        switchView.translatesAutoresizingMaskIntoConstraints = false
        return switchView
    }()
    
    let separatorView: UIView = {
        let view = UIView()

        view.backgroundColor = .systemGray5
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .clear
            contentView.backgroundColor = .clear
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(daySwitch)
        contentView.addSubview(separatorView)
        
        daySwitch.addTarget(
            self,
            action: #selector(switchChanged),
            for: .valueChanged
        )
        
        NSLayoutConstraint.activate([
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    @objc
    private func switchChanged() {
        delegate?.didChangeSwitch(
            on: self,
            isOn: daySwitch.isOn
        )
    }
}
