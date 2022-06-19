//
//  AppCoordinator.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 12.06.2022.
//

import UIKit

class AppCoordinator {
    
    private let navigationController = UINavigationController()
    var rootViewController: UIViewController {
        return navigationController
    }
    
    func start() {
        navigationBarConfiguration(navigationController)
        showMain()
    }
    
    private func showMain() {
        let mainViewController = MainViewController()
        navigationController.pushViewController(mainViewController, animated: true)
    }
    
    private func navigationBarConfiguration (_ controller: UINavigationController) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
}
