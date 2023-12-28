//
//  ViewController.swift
//  SocialLogin
//
//  Created by 김지연 on 12/28/23.
//

import UIKit
import AuthenticationServices



class ViewController: UIViewController {

    
    @IBOutlet var appleLoginButton: ASAuthorizationAppleIDButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonClicked), for: .touchUpInside)
    }

    @objc func appleLoginButtonClicked() {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest() // 애플 아이디 사용 요청
        request.requestedScopes = [.email, .fullName]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self // 로직 연결
        controller.presentationContextProvider = self // presentation
        controller.performRequests() // 신호를 주면 로그인 창 띄워줌
        
    }

}

// 애플 로그인 ui 띄우기
extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window! // view에 꽉 차게
    }
    
    
}

// 로그인 성공 또는 실패에 대한 처리
extension ViewController: ASAuthorizationControllerDelegate {
    
    // 애플 로그인 실패한 경우
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Login Failed \(error.localizedDescription)")
    }
    
    
    // 애플로 로그인 성공한 경우 -> 메인페이지로 이동 등 화면 전환 처리
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            print(appleIDCredential)
            
            let userIdentifier = appleIDCredential.user
            let fullName = appleIDCredential.fullName
            let email = appleIDCredential.email
            
            
            guard let token = appleIDCredential.identityToken, let tokenToString = String(data: token, encoding: .utf8) else {
                print("Token Error")
                return
            }
            
            // UserDefaults에 저장 -> 자동로그인 가능
            
            print(userIdentifier)
            print(fullName ?? "No fullName")
            print(email ?? "No Email")
            print(tokenToString)
            
            if email?.isEmpty ?? true {
                let result = decode(jwtToken: tokenToString)
                print(result) // UserDefaluts 업데이트
            }
            
            // 이메일, 토큰, 이름 -> UserDefaults & API로 서버에 POST
            // 서버에 request 후 response를
            UserDefaults.standard.set(userIdentifier, forKey: "User")
            
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
    
}

// 토큰 디코딩
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
