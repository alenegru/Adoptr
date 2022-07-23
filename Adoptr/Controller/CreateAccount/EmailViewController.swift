//
//  EmailViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 04/08/2021.
//

import UIKit
import Firebase

class EmailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var connectWithAccountButton: UIButton!
    
    let checkbox = Checkbox(frame: CGRect(x: 45, y: 370, width: 25, height: 25 ))
    
    var currentUser: User = User(name: "", email: "", description: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        connectWithAccountButton.setStylingForContinueButton(backgroundColor: UIColor.white, borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor(named: K.textColor)!)
        
        
        emailTextField.becomeFirstResponder()
        emailTextField.delegate = self
        
        //titleLabel.font = UIFont(name: K.fontRegular , size: CGFloat(K.fontSizeTitle))
        configureTextFields()
        
        //view.addSubview(checkbox)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapCheckbox))
        checkbox.addGestureRecognizer(gesture)
    }
    
    @objc
    func didTapCheckbox() {
        checkbox.toggle()
    }
    
    private func configureTextFields() {
        emailTextField.setBottomBorder()
        passwordTextField.setBottomBorder()
    }
    
    @IBAction func continueWithEmail(_ sender: StandardButton) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        if (checkEmail(for: emailTextField)) {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text,
                  !email.isEmpty,
                  !password.isEmpty,
                  password.count >= 6 else {
                    alertUserLoginError()
                    return
            }
            
            //spinner.show(in: view)

            // Firebase Log In
            Auth.auth().signIn(withEmail: email, password: password, completion: {authResult, error in
                
//                DispatchQueue.main.async {
//                    self.spinner.dismiss()
//                }
                    
                guard let result = authResult, error == nil else {
                        print("Failed to log in user with email: \(email)")
                        return
                }

                let user = result.user
                
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                DatabaseManager.shared.getDataFor(path: safeEmail) { result in
                    switch result {
                    case .success(let data):
                        guard let userData = data as? [String:Any],
                            let name = userData["name"] as? String else {
                            return
                        }
                        
                        if let description = userData["description"] {
                            self.currentUser.description = description as! String
                            UserDefaults.standard.setValue(description, forKey: "description")
                        }
                        
                        print("Name: \(name)")
                        UserDefaults.standard.setValue(name, forKey: "name")
                        UserDefaults.standard.setValue(email, forKey: "email")
                        UserDefaults.standard.setValue(safeEmail, forKey: "safeEmail")
                        self.currentUser.name = name
                        self.currentUser.email = email
                        self.performSegue(withIdentifier: K.signInSuccessfully, sender: self)
                    case .failure(let error):
                        print("Failed to read data with error \(error)")
                    }
                }
                
            })
        }
    }
    
    func goToNextView() {
    }
    
    func checkEmail(for textField: UITextField) -> Bool{
        if let email = textField.text {
            if isValidEmail(email) {
                print(email)
//                return true
//                UserDefaults.standard.set(email, forKey: "email")
//                self.performSegue(withIdentifier: K.nameSegue, sender: self)
            } else {
                emailTextField.changeAppearenceForInvalidTextfield()
                return false
            }
        }
        return true
    }

}

extension EmailViewController: UITextFieldDelegate {
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

extension UITextField {
      func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
      }
    
    func changeAppearenceForInvalidTextfield() {
        print("invalid")
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.red.cgColor
    }
}
