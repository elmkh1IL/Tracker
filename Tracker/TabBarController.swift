import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTabBar()
    }
    
    private func setupTabBar() {
        
        let trackersVC = TrackersViewController()
        let statisticsVC = StatisticsViewController()
        
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(resource: .imageTrackers), selectedImage: nil)
        
        statisticsVC.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(resource: .imageStats), selectedImage: nil)
        
        viewControllers = [ UINavigationController(rootViewController: trackersVC),
                            UINavigationController(rootViewController: statisticsVC)
        ]
        
    }
    

}
