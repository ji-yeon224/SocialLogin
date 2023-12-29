//
//  LoginViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 12/28/23.
//

import UIKit
import AuthenticationServices
import KakaoSDKUser

final class LoginViewController: UIViewController {
    
    @IBOutlet var appleLoginButton: ASAuthorizationAppleIDButton!
    
    @IBOutlet var kakaoLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .secondarySystemBackground
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        
    }
    
    
    @IBAction func faceIdTapped(_ sender: UIButton) {
        
        AuthenticationManager.shared.auth()
        
    }
    @objc private func appleLoginTapped() {
        
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
        
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


extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
    
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Apple Login Failed \(error.localizedDescription)")
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIdCredential as ASAuthorizationAppleIDCredential:
            let userIdentifier = appleIdCredential.user
            let fullName = appleIdCredential.fullName
            let email = appleIdCredential.email
            
            guard let token = appleIdCredential.identityToken, let tokenToString = String(data: token, encoding: .utf8) else {
                print("[APPLE LOGIN] Token Error")
                return
            }
            
            if email?.isEmpty ?? true {
                let result = decode(jwtToken: tokenToString)
                print("APPLE TOEKN DECODE", result["email"])
            }
            if let fullName = fullName {
                print(fullName)
            }
            
            UserDefaults.standard.set(userIdentifier, forKey: "User")
            UserDefaults.standard.set("apple", forKey: "Platform")
            
            DispatchQueue.main.async {
                
                self.present(MainViewController(), animated: true)
            }
            
            
            
        case let passwordCredential as ASPasswordCredential:
            print(passwordCredential)
            let userName = passwordCredential.user
            let password = passwordCredential.password
            print(userName, password)
        default: break
        }
    }
    
    
    private func decode(jwtToken jwt: String) -> [String: Any] {
        
        func base64UrlDecode(_ value: String) -> Data? {
            var base64 = value
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            
            let length = Double(base64.lengthOfBytes(using: String.Encoding.utf8))
            let requiredLength = 4 * ceil(length / 4.0)
            let paddingLength = requiredLength - length
            if paddingLength > 0 {
                let padding = "".padding(toLength: Int(paddingLength), withPad: "=", startingAt: 0)
                base64 = base64 + padding
            }
            return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
        }
        func decodeJWTPart(_ value: String) -> [String: Any]? {
            guard let bodyData = base64UrlDecode(value),
                  let json = try? JSONSerialization.jsonObject(with: bodyData, options: []), let payload = json as? [String: Any] else {
                return nil
            }
            
            return payload
        }
        
        let segments = jwt.components(separatedBy: ".")
        return decodeJWTPart(segments[1]) ?? [:]
    }
}
