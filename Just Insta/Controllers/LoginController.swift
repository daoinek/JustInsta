//
//  LoginViewController.swift
//  Just Insta
//
//  Created by Kostya Bershov on 4/23/19.
//  Copyright © 2019 Daoinek Studio. All rights reserved.
//

import UIKit
import Firebase

class LoginController: UIViewController {
    
    
    override func viewDidLoad() {
        stack1.alpha = 0
        stack2.alpha = 0
        stack3.alpha = 0
        super.viewDidLoad()
        nameUser.delegate = self
        passwordText.delegate = self
        emailText.delegate = self
        self.hideKeyboard()
        networkStatus()        
        Auth.auth().addStateDidChangeListener { [weak self](auth, user) in
            if user != nil {
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    loadCoin()
                }
                self?.performSegue(withIdentifier: (self?.segueIdentifier)!, sender: nil)
                self?.stopSpiner = true
            } else {
                UIView.animate(withDuration: 0.5, delay: 0.2, options: .curveEaseInOut, animations: {
                    self?.stack1.alpha = 1
                    self?.stack2.alpha = 1
                    self?.stack3.alpha = 1
                }) { _ in print("Animation Done") }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stopSpiner = false
    }

    // MARK: - Переменные
    let segueIdentifier = "instaSegue"
    var stopSpiner: Bool = false
    var signUp: Bool = true{
    willSet{
        if newValue{
            titleReg.text = "Sign up".localized
            nameUser.isHidden = false
            haveAcc.text = "Have an account?".localized
            regAndLogButton.setTitle("Login".localized, for: .normal)
            stackViewPrivacyPolicy.isHidden = false
        } else{
            titleReg.text = "Login".localized
            nameUser.isHidden = true
            haveAcc.text = "No account?".localized
            regAndLogButton.setTitle("Sign up".localized, for: .normal)
            stackViewPrivacyPolicy.isHidden = true

        }
    }
}
    
    // MARK: - Установка связи
    @IBOutlet weak var regAndLogButton: UIButton!
    @IBOutlet weak var titleReg: UILabel!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var nameUser: UITextField!
    @IBOutlet weak var haveAcc: UILabel!
    @IBOutlet weak var stack1: UIStackView!
    @IBOutlet weak var stack2: UIStackView!
    @IBOutlet weak var stack3: UIStackView!
    @IBOutlet weak var stackViewPrivacyPolicy: UIStackView!
    


    
    // MARK: - Функции
    func createSpinnerView() {
        let child = SpinnerViewController()
        
        addChild(child)
        child.view.frame = view.frame
        view.addSubview(child.view)
        child.didMove(toParent: self)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.stopSpiner == true {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
                timer.invalidate()
            }
        }
        
    }
    
    func networkStatus() {
        if Reachability.isConnectedToNetwork() == true {
            print("Internet connection OK")
            
        } else {
            print("Internet connection FAILED")
            displayWarningLable(withText: "Проблемы с интернет-подключением")
        }
    }
    
    func hideKey() {
        view.endEditing(true)
    }
    
    func displayWarningLable (withText text: String) {
        let alert = UIAlertController(title: "Error".localized, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.stopSpiner = false
        }

    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        signUp = !signUp
    }
    
    
    func confirmEmail() {
        Auth.auth().currentUser?.sendEmailVerification { (error) in
            if error == nil {
                print("Подтверждение на почту отправлено!")
            }
        }
    }

}

// MARK: - Расширение

extension LoginController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let name = nameUser.text!
        let email = emailText.text!
        let password = passwordText.text!
        hideKey()
        
        if signUp {
            if(!name.isEmpty && !email.isEmpty && !password.isEmpty){
                let alertController = UIAlertController(title: "Confirm Registration".localized, message: "Activate your account for a free trial service. The message will be sent to email".localized, preferredStyle: .alert)
                
                let alertAction1 = UIAlertAction(title: "No".localized, style: .cancel) { (alert) in }
                let alertAction2 = UIAlertAction(title: "Yes".localized, style: .default) { (alert) in
                    self.createSpinnerView()
                    Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        if error == nil {
                            if let result = result {
                                print(result.user.uid)
                                let ref = Database.database().reference().child("users")
                                ref.child(result.user.uid).updateChildValues(["name" : name, "email" : email])
                                self.emailText.text = ""
                                self.passwordText.text = ""
                                self.nameUser.text = ""
                                self.confirmEmail()
                            }
                        } else {
                            self.stopSpiner = true
                            if let errCode = AuthErrorCode(rawValue: error!._code) {
                                
                                switch errCode {
                                case .invalidEmail:
                                    print("invalid email")
                                    self.displayWarningLable(withText: NSLocalizedString("Invalid email", comment: ""))
                                case .emailAlreadyInUse:
                                    print("in use")
                                    self.displayWarningLable(withText: NSLocalizedString("Email Already In Use", comment: ""))
                                case .networkError:
                                    print("networkError")
                                    self.displayWarningLable(withText: NSLocalizedString("Internet connection FAILED", comment: ""))
                                default:
                                    print("Other error!")
                                    self.displayWarningLable(withText: NSLocalizedString("Something went wrong", comment: ""))
                                }
                                
                            }

                        }
                    }
                }
                
                alertController.addAction(alertAction1)
                alertController.addAction(alertAction2)
                
                present(alertController, animated: true, completion: nil)
                
            } else {
                self.stopSpiner = true
                displayWarningLable(withText: "Fill in the fields".localized)
            }
        } else {
            if(!email.isEmpty && !password.isEmpty){
                let alertController = UIAlertController(title: "Confirm action".localized, message: nil, preferredStyle: .alert)
                
                let alertAction1 = UIAlertAction(title: "No".localized, style: .cancel) { (alert) in }
                let alertAction2 = UIAlertAction(title: "Yes".localized, style: .default) { (alert) in
                    self.createSpinnerView()
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error == nil {
                            self.emailText.text = ""
                            self.passwordText.text = ""
                            loadCoin()
                        } else {
                            self.stopSpiner = true
                            if let errCode = AuthErrorCode(rawValue: error!._code) {
                                switch errCode {
                                case .userNotFound:
                                    print("UserNotFound")
                                    self.displayWarningLable(withText: "User Not Found".localized)
                                case .wrongPassword:
                                    print("Wrong Password")
                                    self.displayWarningLable(withText: "Wrong Password".localized)
                                case .networkError:
                                    print("networkError")
                                    self.displayWarningLable(withText: "Internet connection FAILED".localized)
                                default:
                                    print("Other error!")
                                    self.displayWarningLable(withText: "Something went wrong".localized)
                                }
                                
                            }
                        }
                        
                        
                    }
                }
                
                alertController.addAction(alertAction1)
                alertController.addAction(alertAction2)
                
                present(alertController, animated: true, completion: nil)
 
            } else {
                self.stopSpiner = true
                displayWarningLable(withText: "Fill in the fields".localized)
            }
        }
        return true
    }
}

extension LoginController {
    func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(InstaController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}
