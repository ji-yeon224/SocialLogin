//
//  LoginViewController1.swift
//  SocialLogin
//
//  Created by 김지연 on 1/1/24.
//

import UIKit
import AuthenticationServices
import KakaoSDKUser
import Combine
import SnapKit
import RxSwift
import RxCocoa


final class LoginViewController1: UIViewController {
    
    private let disposeBag = DisposeBag()
    weak var delegate: LoginViewControllerDelegate?
    private var cancellable = Set<AnyCancellable>()
    
    let appleButton = ASAuthorizationAppleIDButton()
    let kakaoButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "kakao_login_medium_wide")!, for: .normal)
        return view
    }()
    
    let faceIdButton = {
        let view = UIButton()
        view.setTitle("FaceID", for: .normal)
        view.setTitleColor(.systemBlue, for: .normal)
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        view.backgroundColor = .secondarySystemBackground
        
        appleButton.addTarget(self, action: #selector(appleLoginRequest), for: .touchUpInside)
        
        view.addSubview(appleButton)
        view.addSubview(kakaoButton)
        view.addSubview(faceIdButton)
        
        appleButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-100)
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        
        kakaoButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(appleButton.snp.top).offset(-30)
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        
        faceIdButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(kakaoButton.snp.top).offset(-30)
            make.height.equalTo(50)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(40)
        }
        
    }
    
    @objc private func appleLoginRequest() {
        AppleLoginManager.shared.setPresentViewController(self)
        AppleLoginManager.shared.configRequest()
    }
    
    private func bind() {
        
        kakaoButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                KakaoLoginManager.shared.requestLogin()
            }
            .disposed(by: disposeBag)
        
        faceIdButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                AuthenticationManager.shared.auth()
            }
            .disposed(by: disposeBag)
        
        AppleLoginManager.shared.loginSuccess
            .sink { error in
                print(error)
            } receiveValue: { isSuccess in
                if isSuccess {
                    print("apple login success")
                    self.delegate?.login()
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
                    self.delegate?.login()
                } else {
                    print("kakao login fail")
                }
            }
            .store(in: &cancellable)
    }
    
    
}

