//
//  TabBarViewController.swift
//  Plants
//
//  Created by Reina Iketani on 2023/06/20.
//

import UIKit

class TabBarViewController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let appearance = UITabBarAppearance()
        self.tabBar.scrollEdgeAppearance = appearance
        self.delegate = self
    }
    

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }

}
