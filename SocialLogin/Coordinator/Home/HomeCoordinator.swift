//
//  HomeCoordinator.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import Combine

protocol HomeCoordinatorDelegate: AnyObject {
    func didLoggedOut(_ coordinator: HomeCoordinator)
}

final class HomeCoordinator: Coordinator, HomeViewControllerDelegate {
   
    
    var childCoordinators: [Coordinator] = []
    weak var delegate: HomeCoordinatorDelegate?
    
    private var navigationController: UINavigationController!
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let vc = HomeViewController()
        vc.delegate = self
        self.navigationController.viewControllers = [vc]
    }
    
    func logout() {
        self.delegate?.didLoggedOut(self)
    }
    
}
