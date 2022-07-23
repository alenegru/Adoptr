//
//  PhoneVerificationViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 18/07/2021.
//

import UIKit
import Firebase

class PhoneVerificationViewController: UIViewController {
    @IBOutlet weak var codeTextField: CodeTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        codeTextField.configure()
        codeTextField.didEnterLastDigit = { [weak self] code in
            print(code)
            if let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") {
                let credential = PhoneAuthProvider.provider().credential(
                  withVerificationID: verificationID,
                  verificationCode: code
                )
                
                self?.signInUser(credential: credential)
            }
        }
    }
    
    func signInUser(credential: PhoneAuthCredential) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
              if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                // The user is a multi-factor user. Second factor challenge is required.
                let resolver = authError
                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                var displayNameString = ""
                for tmpFactorInfo in resolver.hints {
                  displayNameString += tmpFactorInfo.displayName ?? ""
                  displayNameString += " "
                }
                self.showTextInputPrompt(
                  withMessage: "Select factor to sign in\n\(displayNameString)",
                  completionBlock: { userPressedOK, displayName in
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                      if displayName == tmpFactorInfo.displayName {
                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                      }
                    }
                    PhoneAuthProvider.provider()
                      .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                         multiFactorSession: resolver
                                           .session) { verificationID, error in
                        if error != nil {
                          print(
                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
                          )
                        } else {
                            self.showTextInputPrompt(
                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                            completionBlock: { userPressedOK, verificationCode in
                              let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                .credential(withVerificationID: verificationID!,
                                            verificationCode: verificationCode!)
                              let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                .assertion(with: credential!)
                              resolver.resolveSignIn(with: assertion!) { authResult, error in
                                if error != nil {
                                  print(
                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                  )
                                } else {
                                    self.navigationController?.popViewController(animated: true)
                                }
                              }
                            }
                          )
                        }
                      }
                  }
                )
              } else {
                self.showMessagePrompt(error.localizedDescription)
                return
              }
              // ...
              return
            }
            if let result = authResult {
                UserDefaults.standard.set(result.user.phoneNumber, forKey: "PhoneNumber")
                UserDefaults.standard.set(result.user.uid, forKey: "FirebaseID")
            }
            print("user saved in firebase")
            print(authResult?.user.phoneNumber)
            
            self.performSegue(withIdentifier: K.connectAccountsSegue, sender: self)
            
        }
    }
    
    func showMessagePrompt(_ message: String) {
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alert.addAction(okAction)
      present(alert, animated: false, completion: nil)
    }

    func showTextInputPrompt(withMessage message: String,
                             completionBlock: @escaping ((Bool, String?) -> Void)) {
      let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
        completionBlock(false, nil)
      }
      weak var weakPrompt = prompt
      let okAction = UIAlertAction(title: "OK", style: .default) { _ in
        guard let text = weakPrompt?.textFields?.first?.text else { return }
        completionBlock(true, text)
      }
      prompt.addTextField(configurationHandler: nil)
      prompt.addAction(cancelAction)
      prompt.addAction(okAction)
      present(prompt, animated: true, completion: nil)
    }

}
