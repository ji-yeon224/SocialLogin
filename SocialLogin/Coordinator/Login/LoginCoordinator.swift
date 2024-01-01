//
//  LoginCoordinator.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import Combine

protocol LoginCoordinatorDelegate: AnyObject {
    func didLoggedIn(_ coordinator: LoginCoordinator)
}

final class LoginCoordinator: Coordinator, LoginViewControllerDelegate {
    
    
    var childCoordinators: [Coordinator] = []
    weak var delegate: LoginCoordinatorDelegate?
    
    private var cancellable = Set<AnyCancellable>()
    
    private var navController: UINavigationController?
    init(navController: UINavigationController) {
        self.navController = navController
    }
    
    func start() {
        let vc = LoginViewController1()
        vc.delegate = self
        self.navController?.viewControllers = [vc]
    }
    
    func login() {
        self.delegate?.didLoggedIn(self)
    }
    
}
