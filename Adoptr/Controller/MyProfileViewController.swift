//
//  MyProfileViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 15/05/2022.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class MyProfileViewController: UIViewController {
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    var currentUser: User = User(name: "", email: "", description: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profilePicture.makeRounded()
        nameTextField.setBottomBorder()
        descriptionTextView.setStyling()
        
        guard let name = UserDefaults.standard.value(forKey: "name") as? String,
              let email = UserDefaults.standard.value(forKey: "email") as? String,
              let description = UserDefaults.standard.value(forKey: "description") as? String else {
            return
        }
        
        currentUser.name = name
        currentUser.description = description
        currentUser.email = email
        
        nameTextField.text = currentUser.name
        descriptionTextView.text = (description == "") ? "No description available" : currentUser.description
        
        
        if let profilePicImage = self.getSavedProfilePicture(named: "profilePicture") {
            profilePicture.image = profilePicImage
        } else if let profilePictureURL = UserDefaults.standard.value(forKey: "profilePictureURL") as? String{
             guard let url = URL(string: profilePictureURL) else {
                 return
             }
            print("profile picture URL")
            print(profilePictureURL)
            profilePicture.load(url: url)
            print(self.saveImageFileManager(image: self.profilePicture.image!))
        } else {
            let path = "images/\(currentUser.safeEmail)/\(currentUser.profilePictureFileName)"
            StorageManager.shared.downloadURL(for: path, completion: { result in
                switch result {
                case .success(let url):
                    print("download url")
                    print(url)
                    self.profilePicture.sd_setImage(with: url, completed: {_,_,_,_ in 
                        print(self.saveImageFileManager(image: self.profilePicture.image!))
                    })
                    //print(self.saveImageFileManager(image: self.profilePicture.image!))
                case .failure(let error):
                    print("Failed to get download url: \(error)")
                }
            })
        }
        // Do any additional setup after loading the view.
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Do you really want to log out?", message: "", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Log out", style: .destructive, handler: { _ in
            
            //Log out facebook
            FBSDKLoginKit.LoginManager().logOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                print("logout")
                self.deleteImageFromFileManager()
                self.resetDefaults()
                self.navigationController?.popToRootViewController(animated: true)
            } catch {
                print("Failed to log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    

}
