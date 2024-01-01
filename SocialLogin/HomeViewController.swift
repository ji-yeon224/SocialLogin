//
//  HomeViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import SnapKit
import RxCocoa
import RxSwift

final class HomeViewController: UIViewController {
    
    weak var delegate: HomeViewControllerDelegate?
    
    let button = {
        let view = UIButton()
        view.setTitle("Logout", for: .normal)
        view.backgroundColor = .white
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        view.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalTo(view.safeAreaLayoutGuide)
            make.width.equalTo(100)
            make.height.equalTo(40)
        }
        button.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        
    }
    
    @objc private func logoutTapped() {
        print("Tap")
        delegate?.logout()
    }
    
}
