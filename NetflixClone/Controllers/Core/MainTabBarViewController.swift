//
//  MainTabBarViewController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    // MARK: Properties and outlets
    public let tabViewController1 = UINavigationController(rootViewController:HomeViewController())
    public let tabViewController2 = UINavigationController(rootViewController:UpComingViewController())
    public let tabViewController3 = UINavigationController(rootViewController:SearchViewController())
    public let tabViewController4 = UINavigationController(rootViewController:DownloadsViewController())
    public var arrayOfImageNames = ["house", "play.circle", "magnifyingglass", "arrow.down.to.line"]
    public var arrayOfVCName = ["Home", "Upcoming", "Top Search", "Downloads"]



    // MARK: - View life cycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    // MARK: Helper Methods
    private func setupView() {
        self.tabViewController1.tabBarItem.image = UIImage(systemName: "house")
        self.tabViewController2.tabBarItem.image = UIImage(systemName: "play.circle")
        self.tabViewController3.tabBarItem.image = UIImage(systemName: "magnifyingglass")
        self.tabViewController4.tabBarItem.image = UIImage(systemName: "arrow.down.to.line")

        self.tabViewController1.title = "Home"
        self.tabViewController2.title = "Upcoming"
        self.tabViewController3.title = "Top Search"
        self.tabViewController4.title = "Downloads"

        tabBar.tintColor = .label
        self.setViewControllers([tabViewController1, tabViewController2, tabViewController3, tabViewController4], animated: true)
    }

}
