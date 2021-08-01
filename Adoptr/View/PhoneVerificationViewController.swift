//
//  PhoneVerificationViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 18/07/2021.
//

import UIKit

class PhoneVerificationViewController: UIViewController {
    @IBOutlet weak var codeTextField: CodeTextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        codeTextField.configure()
        codeTextField.didEnterLastDigit = { [weak self] code in
            print(code)
        }
    }

}
