import UIKit

final class OnboardingContentViewController: UIViewController {

    private let page: OnboardingPage

    private let imageView = UIImageView()
    private let titleLabel = UILabel()

    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupImage()
        setupTitle()
    }

    private func setupImage() {

        imageView.image = UIImage(named: page.imageName)
        imageView.contentMode = .scaleAspectFill

        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTitle() {

        titleLabel.text = page.title
        titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.textColor = .black

        view.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            titleLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -250)
        ])
    }
}
