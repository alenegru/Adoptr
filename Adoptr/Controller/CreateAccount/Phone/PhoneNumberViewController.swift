//
//  PhoneNumberViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 01/06/2021.
//

import UIKit
import Firebase
import CoreTelephony

class PhoneNumberViewController: UIViewController {
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var countryCodeButton: UIButton!
    @IBOutlet weak var connectButton: StandardButton!
    
    var currentCountryCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentCountryCode = getCountryCode()
        countryCodeButton.setTitle("+" + currentCountryCode, for: .normal)
        connectButton.layer.cornerRadius = 25.0

        // Do any additional setup after loading the view.
    }

    
    func getCountryCode() -> String {
        guard let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider, let countryCode = carrier.isoCountryCode else { return "" }
        let countryDialingCode = K.countryCodes[countryCode.uppercased()] ?? ""
        return countryDialingCode
    }
    
    @IBAction func continuePressed(_ sender: UIButton) {
        if let phoneNumber = phoneNumberField.text {
            let completePhoneNumber = "+" + currentCountryCode + phoneNumber
            PhoneAuthProvider.provider()
              .verifyPhoneNumber(completePhoneNumber, uiDelegate: nil) { verificationID, error in
                  if let error = error {
                    print(error)
                    return
                  }
                  // Sign in using the verificationID and the code sent to the user
                
                if let finalVerificationID = verificationID {
                    print("Verification ID:")
                    print(finalVerificationID)
                    
                    UserDefaults.standard.set(finalVerificationID, forKey: "authVerificationID")
                }
                
                self.performSegue(withIdentifier: K.verificationCodeSegue, sender: self)
              }
        } else {
            print("Type something")
        }
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        // Get a reference to the second view controller
//        let phoneVerificationViewController = segue.destination as! PhoneVerificationViewController
//
//        phoneVerificationViewController
//
//        // Set a variable in the second view controller with the String to pass
////        phoneVerificationViewController
//    }

}
