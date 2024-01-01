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
                    print("success")
                } else {
                    print("fail")
                }
            }.store(in: &cancellable)

    }
    
    @objc private func kakaoLoginTapped() {
        // 카카오톡 앱 로그인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    self.getUserInfo()
                }
            }
        } else { // 웹으로 로그인
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    self.getUserInfo()
                    //do something
                    _ = oauthToken
                }
            }
        }
    }
    
    private func getUserInfo() {
        UserApi.shared.me() { (user, error) in
            if let error = error {
                print(error)
            }
            else {
                if let user = user {
                    var scopes = [String]()
                    
                    if (user.kakaoAccount?.profileNeedsAgreement == true) { scopes.append("profile") }
                    if (user.kakaoAccount?.emailNeedsAgreement == true) { scopes.append("account_email") }
                    
                    scopes.append("openid")
                    
                    if scopes.count > 0 {
                        print("사용자에게 추가 동의를 받아야 합니다.")

                        // OpenID Connect 사용 시
                        // scope 목록에 "openid" 문자열을 추가하고 요청해야 함
                        // 해당 문자열을 포함하지 않은 경우, ID 토큰이 재발급되지 않음
                        // scopes.append("openid")
                        
                        //scope 목록을 전달하여 카카오 로그인 요청
                        UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (oauthToken, error) in
                            if let error = error {
                                print(error)
                            }
                            else {
                                if let oauthToken = oauthToken {
                                    // oauthToken.idToken -> openid
                                    print(oauthToken.accessToken)
                                    print(oauthToken.refreshToken)
                                }
                                UserApi.shared.me() { (user, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("me() success.")
                                        
                                        if let user = user, let account = user.kakaoAccount {
                                            print(account.email ?? "NO EMAIL")
                                        }
                                        print(user?.kakaoAccount?.profile?.nickname)
                                        
                                        
                                    }
                                }
                                
                                UserDefaults.standard.set("kakao", forKey: "Platform")
                                self.present(MainViewController(), animated: true)
                            }
                        }
                    }
                    else {
                        print("사용자의 추가 동의가 필요하지 않습니다.")
                    }
                }
            }
        }
    }
}
