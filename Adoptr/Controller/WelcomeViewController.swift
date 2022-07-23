//
//  WelcomeViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 16/03/2021.
//
import UIKit
import FirebaseAuth
import FBSDKLoginKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var registerButton: StandardButton!
    @IBOutlet weak var signinButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signinButton.setStylingForSigningButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        validateAuth()
    }
    
    private func validateAuth() {
        if FirebaseAuth.Auth.auth().currentUser != nil ||
            AccessToken.current != nil {
            let tabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "TabBarViewController") as! TabBarViewController
            self.navigationController?.pushViewController(tabBarViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }


}

extension UIButton {
    func setStylingForSigningButton() {
        let borderAlpha : CGFloat = 0.7
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        self.layer.cornerRadius = 25.0
    }
    
    func setStylingForContinueButton(backgroundColor: UIColor, borderColor: UIColor, titleColor: UIColor) {
        self.clipsToBounds = true
        self.backgroundColor = backgroundColor
        self.setTitleColor(titleColor, for: .normal)
        self.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 20)
        
        //let borderAlpha : CGFloat = 0.7
        
        self.layer.borderWidth = 1.0
        self.layer.borderColor = borderColor.cgColor
        self.layer.cornerRadius = 25.0
    }
}
