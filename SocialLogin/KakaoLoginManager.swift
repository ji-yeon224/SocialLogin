//
//  KakaoLoginManager.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import KakaoSDKUser
import KakaoSDKAuth
import KakaoSDKCommon
import Combine

final class KakaoLoginManager {
    
    static let shared = KakaoLoginManager()
    private init() { }
    
    let loginSuccess = PassthroughSubject<Bool, Never>()
    
    
    func requestLogin() {
        // 카카오톡 앱 로그인
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(_, error) in
                if let error = error {
                    print(error)
                    self.loginSuccess.send(false)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    self.getUserInfo()
                }
            }
        } else { // 웹으로 로그인
            UserApi.shared.loginWithKakaoAccount {(_, error) in
                if let error = error {
                    print(error)
                    self.loginSuccess.send(false)
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    self.getUserInfo()
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
                    
//                    scopes.append("openid")
                    
                    if scopes.count > 0 {
                        print("사용자에게 추가 동의를 받아야 합니다.")

                        // OpenID Connect 사용 시
                        // scope 목록에 "openid" 문자열을 추가하고 요청해야 함
                        // 해당 문자열을 포함하지 않은 경우, ID 토큰이 재발급되지 않음
                         scopes.append("openid")
                        
                        //scope 목록을 전달하여 카카오 로그인 요청
                        
                        
                        UserApi.shared.loginWithKakaoAccount(scopes: scopes) { (oauthToken, error) in
                            if let error = error {
                                print("aggrement fail ", error)
                                self.loginSuccess.send(false)
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
                                        self.loginSuccess.send(false)
                                    }
                                    else {
                                        print("me() success.")
                                        
                                        if let user = user, let account = user.kakaoAccount {
                                            print(account.email ?? "NO EMAIL")
                                        }
//                                        print(user?.kakaoAccount?.profile?.nickname)
                                        
                                        
                                    }
                                }
                                
                                UserDefaults.standard.set("kakao", forKey: "Platform")
//                                self.present(MainViewController(), animated: true)
                                self.loginSuccess.send(true)
                            }
                        }
                    }
                    else {
                        print("사용자의 추가 동의가 필요하지 않습니다.")
                        self.loginSuccess.send(true)
                    }
                }
            }
        }
    }
    
    func kakaoUnlinkAccount() {
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("unlink() success.")
            }
        }
    }
    
    func kakaoLogout() {
        UserApi.shared.logout {(error) in
            if let error = error {
                print(error)
            }
            else {
                print("logout() success.")
            }
        }
    }
    
    private func isValidToken() {
        if (AuthApi.hasToken()) {
            UserApi.shared.accessTokenInfo { (_, error) in
                if let error = error {
                    if let sdkError = error as? SdkError, sdkError.isInvalidTokenError() == true  {
                        //로그인 필요
                    }
                    else {
                        //기타 에러
                    }
                }
                else {
                    //토큰 유효성 체크 성공(필요 시 토큰 갱신됨)
                }
            }
        }
        else {
            //로그인 필요
        }
    }
    
}
