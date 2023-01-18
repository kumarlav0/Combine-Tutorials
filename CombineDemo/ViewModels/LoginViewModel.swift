//
//  LoginViewModel.swift
//  CombineDemo
//
//  Created by Kumar Lav on 17/01/23.
//

import Combine
import Foundation

class LoginViewModel: ObservableObject {

    enum LoginState {
        case loading
        case success
        case failed
        case none
    }

    @Published var email = ""
    @Published var password = ""
    @Published var state: LoginState = .none

    var isValidUsernamePublisher: AnyPublisher<Bool, Never> {
        $email
            .map { $0.isValidEmail }
            .eraseToAnyPublisher()
    }

    var isValidPasswordPublisher: AnyPublisher<Bool, Never> {
        $password
            .map { !$0.isEmpty && $0.count >= 5 }
            .eraseToAnyPublisher()
    }

    var isLoginEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isValidUsernamePublisher, isValidPasswordPublisher)
            .map { $0 && $1 }
            .eraseToAnyPublisher()
    }

    func submitLogin() {
        state = .loading
        // hardcoded 3 seconds delay, to call API and get response
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) { [weak self] in
            guard let self = self else { return }
            if self.isCorrectLogin() {
                self.state = .success
            } else {
                self.state = .failed
            }
        }
    }
}

extension LoginViewModel {
    func isCorrectLogin() -> Bool {
        // Hardcoded Example of Login Credential
        return email == "kumar@combine.com" && password == "12345"
    }
}
