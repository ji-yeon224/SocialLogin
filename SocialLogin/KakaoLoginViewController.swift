//
//  KakaoLoginViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 12/28/23.
//

import UIKit
import KakaoSDKUser

final class KakaoLoginViewController: UIViewController {
    
    
    @IBOutlet var kakaoLoginButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        kakaoLoginButton.addTarget(self, action: #selector(loginButton), for: .touchUpInside)
    }
    
    @objc private func loginButton() {
        
        if (UserApi.isKakaoTalkLoginAvailable()) {
            print("kakao ")
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    
                    //do something
                    let token = oauthToken?.accessToken
                    print(token)
                    self.getUserInfo()
                }
            }
        } else {
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
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
                                print(oauthToken?.accessToken)
                                print(oauthToken?.refreshToken)
                                UserApi.shared.me() { (user, error) in
                                    if let error = error {
                                        print(error)
                                    }
                                    else {
                                        print("me() success.")
                                        
                                        //do something
                                        let user = user
                                        print(user?.kakaoAccount?.email)
                                        
                                    }
                                }
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
