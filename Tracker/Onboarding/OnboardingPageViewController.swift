import UIKit

final class OnboardingPageViewController: UIPageViewController {

    private lazy var pages: [UIViewController] = [
        OnboardingContentViewController(
            page: OnboardingPage(
                imageName: "onboardingFirst",
                title: "Отслеживайте только\nто, что хотите"
            )
        ),
        OnboardingContentViewController(
            page: OnboardingPage(
                imageName: "onboardingSecond",
                title: "Даже если это\nне литры воды и йога"
            )
        )
    ]

    private let pageControl = UIPageControl()

    private let button = UIButton(type: .system)

    init() {
        super.init(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        setViewControllers(
            [pages[0]],
            direction: .forward,
            animated: false
        )

        setupButton()
        setupPageControl()
    }
}

private extension OnboardingPageViewController {

    func setupPageControl() {

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray

        view.addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

private extension OnboardingPageViewController {

    func setupButton() {

        button.setTitle("Вот это технологии!", for: .normal)

        button.backgroundColor = .black
        button.tintColor = .white

        button.layer.cornerRadius = 16

        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)

        button.addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )

        view.addSubview(button)

        button.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc
    func buttonTapped() {

        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")

        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else {
                return
            }

        sceneDelegate.switchToMainInterface()
        
        }
}

extension OnboardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        guard let index = pages.firstIndex(of: viewController),
              index > 0 else {
            return nil
        }

        return pages[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        guard let index = pages.firstIndex(of: viewController),
              index < pages.count - 1 else {
            return nil
        }

        return pages[index + 1]
    }
}

extension OnboardingPageViewController: UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        guard completed,
              let current = viewControllers?.first,
              let index = pages.firstIndex(of: current) else {
            return
        }

        pageControl.currentPage = index
        
    }
}
