import UIKit

final class EmojiColorCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "EmojiColorCell"
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.layer.cornerRadius = 16
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(colorView)
        colorView.isHidden = true
        
        NSLayoutConstraint.activate([
            
            titleLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    func configure(with emoji: String) {
        titleLabel.isHidden = false
        colorView.isHidden = true
        
        titleLabel.text = emoji
    }
    
    func configure(with color: UIColor) {
        titleLabel.isHidden = true
        colorView.isHidden = false
        
        colorView.backgroundColor = color
    }
    
    func setSelected(_ selected: Bool) {
        
        if titleLabel.isHidden {
            
            contentView.backgroundColor = selected
            ? colorView.backgroundColor?.withAlphaComponent(0.3)
            : .clear
            
            contentView.layer.cornerRadius = 16
            
        } else {
            
            contentView.backgroundColor = selected
            ? UIColor.trackerEmojiSelection
            : .clear
        }
    }
}
