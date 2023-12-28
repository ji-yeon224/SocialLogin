//
//  MainViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 12/28/23.
//

import UIKit

final class MainViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("login success")
        if let platform = UserDefaults.standard.string(forKey: "Platform") {
            print(platform)
        }
        view.backgroundColor = .white
//        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        if let platform = UserDefaults.standard.string(forKey: "Platform") {
            switch platform {
            case "apple":
                UserDefaults.standard.set(nil, forKey: "Platform")
                UserDefaults.standard.set(nil, forKey: "User")
            case "kakao":
                UserDefaults.standard.set(nil, forKey: "Platform")
            default: break
            }
        }
        
        print("logout")
        view?.window?.rootViewController = LoginViewController()
        view.window?.makeKeyAndVisible()
        
    }
    
    
    @objc private func logoutButtonTapped() {
        
        if let platform = UserDefaults.standard.string(forKey: "Platform") {
            switch platform {
            case "apple":
                UserDefaults.standard.set(nil, forKey: "Platform")
                UserDefaults.standard.set(nil, forKey: "User")
            case "kakao":
                UserDefaults.standard.set(nil, forKey: "Platform")
            default: break
            }
        }
        
        
        view?.window?.rootViewController = LoginViewController()
        view.window?.makeKeyAndVisible()
        
        
    }
    
}
