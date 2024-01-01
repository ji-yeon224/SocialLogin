//
//  AppleLoginManager.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import AuthenticationServices
import Combine

final class AppleLoginManager: NSObject {
     
    static let shared = AppleLoginManager()
    override init() { }
    private weak var viewController: UIViewController?
    
    let loginSuccess = PassthroughSubject<Bool, Never>()
    
    func setPresentViewController(_ view: UIViewController) {
        self.viewController = view
    }
    
    func configRequest() {
        let appleIdProvider = ASAuthorizationAppleIDProvider()
        let request = appleIdProvider.createRequest()
        request.requestedScopes = [.email, .fullName]
        
        

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    
    
}

extension AppleLoginManager: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return viewController!.view.window!
    }
    
    
}

extension AppleLoginManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print(error)
        loginSuccess.send(false)
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user //userIdentifier
            let userName = appleIDCredential.fullName //fullName
            let userEmail = appleIDCredential.email //email
            print(userName ?? "No Name", userEmail ?? "No Email")
            UserDefaults.standard.set(userIdentifier, forKey: "User")
            UserDefaults.standard.set("apple", forKey: "Platform")
            loginSuccess.send(true)
        }
        
        
    }
    
}
