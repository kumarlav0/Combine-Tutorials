//
//  ViewController.swift
//  CombineDemo
//
//  Created by Kumar Lav on 17/01/23.
//

import UIKit
import Combine

class LoginViewController: UIViewController {
    @IBOutlet weak var layoutView: UIView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var loginBtn: CustomButton!
    @IBOutlet weak var errorLabel: UILabel!

    private var viewModel = LoginViewModel()
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
    }

    @IBAction func didLoginAction(_ sender: UIButton) {
        viewModel.submitLogin()
    }

}

extension LoginViewController {
    private func setupPublishers() {
        // update published variables once text changed for both text fields
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: emailTF)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.email, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTF)
            .map { ($0.object as! UITextField).text ?? "" }
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)

        // subscribers
        viewModel.isLoginEnabled
            .assign(to: \.isEnabled, on: loginBtn)
            .store(in: &cancellables)

        viewModel.$state
            .sink { [weak self] state in
                switch state {
                case .loading:
                    self?.loginBtn.isEnabled = false
                    self?.loginBtn.setTitle("Loading..", for: .normal)
                    self?.hideError(true)
                case .success:
                    self?.showHomeScreen()
                    self?.resetButton()
                    self?.hideError(true)
                case .failed:
                    self?.resetButton()
                    self?.hideError(false)
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }
}

extension LoginViewController {
    private func uiSetup() {
        let disableTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)
        let ebabledTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        let disabledColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 0.5)
        let enabledColor = #colorLiteral(red: 1, green: 0.5843137255, blue: 0, alpha: 1)
        loginBtn.setTitleColor(disableTextColor, for: .disabled)
        loginBtn.setTitleColor(ebabledTextColor, for: .normal)
        loginBtn.setBackgroundColor(disabledColor, for: .disabled)
        loginBtn.setBackgroundColor(enabledColor, for: .normal)
        layoutView.layer.cornerRadius = 10
        loginBtn.layer.cornerRadius = 5
        passwordTF.placeholderColor(color: .white)
        emailTF.placeholderColor(color: .white)
        hideKeyboardWhenTappedAround()
        setupPublishers()
    }

    private func resetButton() {
        loginBtn.setTitle("Login", for: .normal)
        loginBtn.isEnabled = true
    }

    private func showHomeScreen() {
        // Navigate to Dashboard or Home screen....
        guard let homevc = storyboard?.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController else { return }
        present(homevc, animated: true, completion: nil)
    }

    private func hideError(_ isHidden: Bool) {
        // Show Hide Error if any occur on login.....
        errorLabel.isHidden = isHidden
        errorLabel.fadeIn()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) { [weak self] in
            self?.errorLabel.fadeOut()
        }
    }
}
