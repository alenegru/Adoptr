//
//  RegisterViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 20/03/2022.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reEnterPasswordField: UITextField!
    @IBOutlet weak var createAccountButton: StandardButton!
    @IBOutlet weak var connectWithAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextFields()
        // Do any additional setup after loading the view.
        createAccountButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        connectWithAccountButton.setStylingForContinueButton(backgroundColor: UIColor.white, borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor(named: K.textColor)!)
    }
    
    private func configureTextFields() {
        emailField.setBottomBorder()
        passwordField.setBottomBorder()
        reEnterPasswordField.setBottomBorder()
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton?) {
        UserDefaults.standard.setValue(false, forKey: "facebookLogin")
        guard let email = emailField.text,
            let password = passwordField.text,
            let rePassword = reEnterPasswordField.text,
            !email.isEmpty,
            !password.isEmpty,
            password == rePassword,
            password.count >= 6 else {
            alertUserRegisterError()
                return
        }
        
        DatabaseManager.shared.userExists(with: email, completion: { exists, user in
                                          if (exists) {
                                          self.alertUserRegisterError(message: "User with this email already exists.")
            } else {
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue(password, forKey: "password")
                
                self.performSegue(withIdentifier: K.nameSegue, sender: self)
            }
        })

    }

}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonPressed(nil)
        }

        return true
    }

}

extension UIViewController {
    func alertUserRegisterError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
