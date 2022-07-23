//
//  PetProfileCreationViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 06/05/2022.
//

import UIKit

class PetProfileCreationViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var continueButton: StandardButton!
    
    let placeHolderTextColor = UIColor.lightGray
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        continueButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        configureTextField()
        configureTextView()
        nameTextField.delegate = self
        descriptionTextView.delegate = self
        nameTextField.becomeFirstResponder()
        // Do any additional setup after loading the view.
    }
    
    private func configureTextField() {
        nameTextField.setBottomBorder()
    }
    
    private func configureTextView() {
        descriptionTextView.setStyling()
    }
    
    @IBAction func continueButtonPressed(_ sender: StandardButton) {
        nameTextField.resignFirstResponder()
        checkName(for: nameTextField)
    }
    
    func checkName(for textField: UITextField) {
        if let name = nameTextField.text,
        let description = descriptionTextView.text {
            if name != "" {
                print(name)
                UserDefaults.standard.set(name, forKey: "pet-name")
                UserDefaults.standard.set(description, forKey: "pet-description")
                self.performSegue(withIdentifier: K.detailsSegue, sender: self)
            } else {
                nameTextField.changeAppearenceForInvalidTextfield()
            }
        }
    }
    

}

extension PetProfileCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkName(for: textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.layer.borderWidth = 0.0
    }
}

extension PetProfileCreationViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeHolderTextColor && textView.isFirstResponder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing (_ textView: UITextView) {
        if textView.text.isEmpty || textView.text == "" {
            textView.textColor = .lightGray
            textView.text = "Enter description (Optional)"
        }
    }
}
