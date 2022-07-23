//
//  NameViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 20/09/2021.
//

import UIKit
import FBSDKLoginKit

class NameViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var continueButton: StandardButton!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.makeRounded()
        profilePicture.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfilePicture))
        profilePicture.addGestureRecognizer(gesture)
        continueButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        if let petAdoption = UserDefaults.standard.value(forKey: "petAdoption") as? Bool {
            print("pet adoption boolean exists")
            if (petAdoption) {
                print("is true")
                continueButton.setTitle("FINISH", for: .normal)
            }
        }
        configureTextField()
        configureTextView()
        nameTextField.delegate = self
        if let name = UserDefaults.standard.value(forKey: "name") as? String,
           let profilePicUrl = UserDefaults.standard.value(forKey: "pictureUrl") as? String{
            nameTextField.text = name
            guard let url = URL(string: profilePicUrl) else {
                return
            }
            profilePicture.load(url: url)
        }
        descriptionTextView.delegate = self
        nameTextField.becomeFirstResponder()

    }
    
    @objc private func didTapProfilePicture() {
        presentPhotoActionSheet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.backAction(sender:)))
        navigationController?.navigationBar.tintColor = UIColor(named: K.accentColor)
    }
    
    @objc func backAction(sender: AnyObject) {
         alertUserOfLosingData()
    }
    
    let placeHolderTextColor = UIColor.lightGray
    
    private func configureTextField() {
        nameTextField.setBottomBorder()
    }
    
    private func configureTextView() {
        descriptionTextView.setStyling()
    }
    
    @IBAction func editButtonPressed(_ sender: UIButton) {
        presentPhotoActionSheet()
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
                UserDefaults.standard.set(name, forKey: "name")
                UserDefaults.standard.set(description, forKey: "description")
                print("Was image saved?")
                print(saveImageFileManager(image: profilePicture.image!))
                
                self.performSegue(withIdentifier: K.locationSegue, sender: self)
            } else {
                nameTextField.changeAppearenceForInvalidTextfield()
            }
        }
    }
    
}

extension NameViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        checkName(for: textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextField.layer.borderWidth = 0.0
    }
}

extension NameViewController: UITextViewDelegate {
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


extension UIViewController {
    func goBackAndDeleteData() {
        _ = navigationController?.popViewController(animated: true)
        resetDefaults()
        self.deleteImageFromFileManager()
        FBSDKLoginKit.LoginManager().logOut()
    }
    
    func resetDefaults() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func alertUserToCreateAccount(message: String) {
        let alert = UIAlertController(title: "Create an account!",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title:"Yes",
                                      style: .default) { (UIAlertAction) in
            UserDefaults.standard.setValue(true, forKey: "petAdoption")
            let registerViewController = self.storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
            self.navigationController?.pushViewController(registerViewController, animated: true)
        })
        present(alert, animated: true)
    }
    
    func alertUserOfLosingData(message: String = "By quitting the registration process, all information will be deleted.") {
        let alert = UIAlertController(title: "Are you sure?",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"No",
                                      style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title:"Yes",
                                      style: .destructive) { (UIAlertAction) in
            self.goBackAndDeleteData()
                                      })
        present(alert, animated: true)
    }
    
    func alertUserToAddAtLeastOnePhoto(message: String = "In order to create a pet profile, at least one photo needs to be added.") {
        let alert = UIAlertController(title: "Whoops!",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}

extension NameViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture", message: "How would you like to select a picture", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take photo", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose photo", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        profilePicture.image = selectedImage
    }
}
