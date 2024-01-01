//
//  AppCoordinator.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import Combine

final class AppCoordinator: Coordinator, LoginCoordinatorDelegate, HomeCoordinatorDelegate
{
    
    var loggedIn = PassthroughSubject<Bool, Never>()
    var childCoordinators: [Coordinator] = []
    
    var isLoggedIn: Bool = false
    
    private var navController: UINavigationController!
    init(navController: UINavigationController) {
        self.navController = navController
    }
    
    func start() {
        if self.isLoggedIn {
            showHomeViewController()
        } else {
            showLoginController()
        }
        
    }
    
    func showLoginController() {
        let coordinator = LoginCoordinator(navController: self.navController)
        coordinator.delegate = self
        coordinator.start()
        self.childCoordinators.append(coordinator)
    }
    
    func showHomeViewController() {
        let coordinator = HomeCoordinator(navigationController: self.navController)
        coordinator.delegate = self
        coordinator.start()
        self.childCoordinators.append(coordinator)
    }
    
    func didLoggedIn(_ coordinator: LoginCoordinator) {
        self.isLoggedIn = true
        self.childCoordinators = self.childCoordinators.filter { $0 !== coordinator }
        self.showHomeViewController()
    }
    
    func didLoggedOut(_ coordinator: HomeCoordinator) {
        print("LL")
        isLoggedIn = false
        self.childCoordinators = self.childCoordinators.filter { $0 !== coordinator }
        self.showLoginController()
        
    }
    
    
    
}
