//
//  ResetPasswordViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 08/06/2022.
//

import UIKit
import Firebase

class ResetPasswordViewController: UIViewController {
    
    @IBOutlet weak var sendEmailButton: StandardButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendEmailButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        
        emailTextField.delegate = self
        emailTextField.setBottomBorder()
    }
    
    func checkEmail(for textField: UITextField) -> Bool{
        if let email = textField.text {
            if isValidEmail(email) {
                print(email)
            } else {
                emailTextField.changeAppearenceForInvalidTextfield()
                return false
            }
        }
        return true
    }
    
    @IBAction func sendEmailButtonTapped(_ sender: StandardButton) {
        emailTextField.resignFirstResponder()
        if (checkEmail(for: emailTextField)) {
            guard let email = emailTextField.text else {
                alertUserLoginError()
                return
            }
            let auth = Auth.auth()
            auth.sendPasswordReset(withEmail: email) { (error) in
                if error != nil {
                    self.alertUserOfError(with: String(describing: error))
                    return
                }
                self.alertUserSuccess()
            }
        }
    }
    
}

extension ResetPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        _ = checkEmail(for: textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextField.layer.borderWidth = 0.0
    }
    

    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
}
