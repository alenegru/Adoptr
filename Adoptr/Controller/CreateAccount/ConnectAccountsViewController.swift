//
//  ConnectAccountsViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 15/08/2021.
//

import UIKit
import FBSDKLoginKit

class ConnectAccountsViewController: UIViewController, LoginButtonDelegate {
    
    @IBOutlet weak var facebookLoginButton: FBLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookLoginButton.setStylingForSigningButton()
        facebookLoginButton.layer.masksToBounds = true
        
        for const in facebookLoginButton.constraints{
            if const.firstAttribute == NSLayoutConstraint.Attribute.height && const.constant == 28{
            facebookLoginButton.removeConstraint(const)
          }
        }
        
        let buttonText = NSAttributedString(string: "CONTINUE WITH FACEBOOK")
        facebookLoginButton.setAttributedTitle(buttonText, for: .normal)
        
        
        if let token = AccessToken.current,
            !token.isExpired {
            let token = token.tokenString
            
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
            request.start(completion: { connection, result, error in
                print(result)
            })
        } else {
            self.facebookLoginButton.delegate = self
            self.facebookLoginButton.permissions = ["email", "public_profile"]
        }
        
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 44))
        view.addSubview(navBar)
        
        let navItem = UINavigationItem()
        let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancel))
        navItem.rightBarButtonItem  = cancelBarButtonItem
        
        navBar.setItems([navItem], animated: false)
    }
    
    @objc func cancel(){
        print("clicked")
        dismiss(animated: true, completion: nil)
   }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        request.start(completion: { connection, result, error in
            guard let result = result as? [String: Any],
                error == nil else {
                    print("Failed to make facebook graph request")
                    return
            }
            
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String: Any],
                let data = picture["data"] as? [String: Any],
                let pictureUrl = data["url"] as? String else {
                    print("Failed to get data")
                    return
            }
            let fullName = "\(firstName) \(lastName)"
            
            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(true, forKey: "facebookLogin")
            UserDefaults.standard.setValue(pictureUrl, forKey: "pictureUrl")
            
            let navigationController = self.presentingViewController as! UINavigationController
            let senderController = navigationController.topViewController
            self.dismiss(animated: true, completion: { () -> Void in
                DatabaseManager.shared.userExists(with: email, completion: { exists, user in
                                if !exists {
                                    UserDefaults.standard.setValue(fullName, forKey: "name")
                                    senderController!.performSegue(withIdentifier: K.nameSegue, sender: self)
                                } else {
                                    UserDefaults.standard.setValue(user!.name, forKey: "name")
                                    UserDefaults.standard.setValue(user!.description, forKey: "description")
                                    senderController!.performSegue(withIdentifier: K.signInSuccessfully, sender: self)
                                }
                })
            })
        })
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    @IBAction func continueWithApplePressed(_ sender: UIButton) {
//        self.performSegue(withIdentifier: K.goToCreateAccountSegue, sender: self)
        //weak var pvc = RegisterViewController()
        let navigationController = self.presentingViewController as! UINavigationController
        let senderController = navigationController.topViewController
        dismiss(animated: true, completion: { () -> Void in
            if (senderController is EmailViewController) {
                senderController!.performSegue(withIdentifier: K.signInSuccessfully, sender: self)
            } else {
                senderController!.performSegue(withIdentifier: K.nameSegue, sender: self)
            }

        })
    }
    
    
}
