//
//  LoginViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 12/28/23.
//

import UIKit
import AuthenticationServices
import KakaoSDKUser
import Combine

final class LoginViewController: UIViewController {
    
    @IBOutlet var appleLoginButton: ASAuthorizationAppleIDButton!
    
    @IBOutlet var kakaoLoginButton: UIButton!
    
    
    
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        bind()
        
    }
    
    @IBAction func kakaoUnlink(_ sender: UIButton) {
        KakaoLoginManager.shared.kakaoUnlinkAccount()
        
    }
    
    @IBAction func faceIdTapped(_ sender: UIButton) {
        
        AuthenticationManager.shared.auth()
        
    }
    @objc private func appleLoginTapped() {
        AppleLoginManager.shared.setPresentViewController(self)
        AppleLoginManager.shared.configRequest()
    }
    
    private func bind() {
        AppleLoginManager.shared.loginSuccess
            .sink { error in
                print(error)
            } receiveValue: { isSuccess in
                if isSuccess {
                    print("apple login success")
                } else {
                    print("apple login fail")
                }
            }.store(in: &cancellable)
        
        KakaoLoginManager.shared.loginSuccess
            .sink { error in
                print(error)
            } receiveValue: { isSuccess in
                if isSuccess {
                    print("kakao login success")
                } else {
                    print("kakao login fail")
                }
            }
            .store(in: &cancellable)


    }
    
    @objc private func kakaoLoginTapped() {
        
        KakaoLoginManager.shared.requestLogin()
        
    }
    
    
}
