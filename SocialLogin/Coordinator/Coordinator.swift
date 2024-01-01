//
//  Coordinator.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import Foundation

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}
