//
//  ApplicationController.swift
//  NetflixClone
//
//  Created by Assem on 19/09/2022.
//

import UIKit

public class ApplicationController {
    public var window: UIWindow
    let navBar = MainTabBarViewController()

    public init(window: UIWindow) {
        self.window = window
    }

    public func loadInitialView() {
        window.overrideUserInterfaceStyle = .dark
        window.rootViewController = navBar
        window.makeKeyAndVisible()
    }
}
