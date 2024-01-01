//
//  AuthenticationManager.swift
//  SocialLogin
//
//  Created by 김지연 on 12/29/23.
//

import Foundation
import LocalAuthentication // FaceID, TouchID
import Combine

final class AuthenticationManager {
    static let shared = AuthenticationManager()
    var faceIdSuccess = PassthroughSubject<Bool, Error>()
    private init() { }
    
    var selectedPolicy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics // 생체 인증
    
    func auth() {
        
        let context = LAContext()
        context.localizedCancelTitle = "FaceID 인증 취소"
        context.localizedFallbackTitle = "비밀번호로 대신 인증하기"
        
        context.evaluatePolicy(selectedPolicy, localizedReason: "페이스 아이디 인증이 필요합니다.") { result, error in
            print(result) // Bool 값
            self.faceIdSuccess.send(result)
            if let error {
                let code = error._code
                let laError = LAError(LAError.Code(rawValue: code)!)
                print(laError)
            }
            
        }
        
        
    }
    
    // FaceID 쓸 수 있는 상태인지 여부 확인
    func checkPolicy() -> Bool {
        let context = LAContext()
        let policy: LAPolicy = selectedPolicy
        return context.canEvaluatePolicy(policy, error: nil)
    }
    
    // FaceID 변경 시
    func isFaceIDChanged() -> Bool {
        let context = LAContext()
        context.canEvaluatePolicy(selectedPolicy, error: nil)
        
        let state = context.evaluatedPolicyDomainState // 생체 인증 정보
        
        // 생체 인증 정보를 UserDefaults에 저장 (자동 로그인)
        // 기존 저장된 domainState와 새롭게 변경된 domainState를 비교
        print(state)
        return false // 로직 추가
    }
}
