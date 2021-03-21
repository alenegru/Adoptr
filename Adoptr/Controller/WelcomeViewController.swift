//
//  WelcomeViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 16/03/2021.
//
import UIKit

class WelcomeViewController: UIViewController {
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signinButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let borderAlpha : CGFloat = 0.7
        
        signinButton.layer.borderWidth = 1.0
        signinButton.layer.borderColor = UIColor(white: 1.0, alpha: borderAlpha).cgColor
        signinButton.layer.cornerRadius = 25.0
        registerButton.layer.cornerRadius = 25.0
        
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

