//
//  LoginViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 12/28/23.
//

import UIKit
import AuthenticationServices

final class LoginViewController: UIViewController {
    
    @IBOutlet var appleLoginButton: ASAuthorizationAppleIDButton!
    
    @IBOutlet var kakaoLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appleLoginButton.addTarget(self, action: #selector(appleLoginTapped), for: .touchUpInside)
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginTapped), for: .touchUpInside)
        
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
                print(result)
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
