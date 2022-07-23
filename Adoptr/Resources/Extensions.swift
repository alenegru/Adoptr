//
//  Extensions.swift
//  Adoptr
//
//  Created by Alexandra Negru on 27/04/2022.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit

extension UIImageView {
    func load(url: URL) {
            DispatchQueue.global().async { [weak self] in
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self?.image = image
                        }
                    }
                }
            }
        }
    
    func makeRounded() {
        self.layer.borderWidth = 0.5
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

extension UIViewController {
    func saveImageFileManager(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("profilePicture.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedProfilePicture(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func deleteImageFromFileManager() {
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return
        }
        
        if let fileNames = try? FileManager.default.contentsOfDirectory(atPath: directory.path!) {
            for file in fileNames {
                if file.contains("profilePicture.png") {
                    let filePath = URL(fileURLWithPath: directory.path!).appendingPathComponent(file).absoluteURL
                    _ = try? FileManager.default.removeItem(at: filePath)
                }
            }
        }
    }
}

extension UIViewController {
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter valid information to log in.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func alertUserSuccess() {
        let alert = UIAlertController(title: "Successful!",
                                      message: "Email for password reset was sent successfully.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func alertUserOfError(with error: String) {
        let alert = UIAlertController(title: "Error",
                                      message: error,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"OK",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    
    func createUserWithFacebook(completion: @escaping ((Bool, User) -> Void)) {
        if let name = UserDefaults.standard.value(forKey: "name") as? String,
           let emailAddress = UserDefaults.standard.value(forKey: "email") as? String,
           let description = UserDefaults.standard.value(forKey: "description") as? String,
           let pictureUrl = UserDefaults.standard.value(forKey: "pictureUrl") as? String {
            let currentUser = User(name: name, email: emailAddress, description: description)
            DatabaseManager.shared.insertUser(with: currentUser, completion: { success in
                    if success {
                        guard let url = URL(string: pictureUrl) else {
                            return
                        }

                        print("Downloading data from facebook image")

                        URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
                            guard let data = data else {
                                print("Failed to get data from facebook")
                                return
                            }

                            print("got data from FB, uploading...")

                            // upload iamge
                            let filename = currentUser.profilePictureFileName
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, currentUserEmail: currentUser.safeEmail, completion: { result in
                                switch result {
                                case .success(
                                        let downloadUrl):
                                    print(downloadUrl)
                                case .failure(let error):
                                    print("Storage maanger error: \(error)")
                                }
                            })
                        }).resume()
                    }
                })
            if let token = AccessToken.current,
                !token.isExpired {
                let token = token.tokenString
                
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
//                    guard let strongSelf = self else {
//                        return
//                    }

                    guard authResult != nil, error == nil else {
                        if let error = error {
                            print("Facebook credential login failed, MFA may be needed - \(error)")
                        }
                        return
                    }

                    print("Successfully logged user in")
                    //strongSelf.createPetProfile(currentUser)
                    completion(true, currentUser)
                })
            }
        }
    }
    
    func createUserWithEmail(completion: @escaping ((Bool, User) -> Void)) {
        //spinner.show(in: view)
        let email = UserDefaults.standard.value(forKey: "email") as! String
        let password = UserDefaults.standard.value(forKey: "password") as! String
        let name = UserDefaults.standard.value(forKey: "name") as! String
        let description = UserDefaults.standard.value(forKey: "description") as! String
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                self.alertUserRegisterError(message: "User with this email already exists.")
                //self.spinner.dismiss()
                return
            }

            DispatchQueue.main.async {
                //self.spinner.dismiss()
            }

            let currentUser = User(name: name, email: email, description: description)
            DatabaseManager.shared.insertUser(with: currentUser, completion: { success in
                if success {
                    // upload profile picture
                    guard let profilePicture = self.getSavedProfilePicture(named: "profilePicture"), let profilePicData = profilePicture.pngData() else {
                        return
                    }
                    
                    StorageManager.shared.uploadProfilePicture(with: profilePicData, fileName: currentUser.profilePictureFileName, currentUserEmail: currentUser.safeEmail, completion: { result in
                        switch result {
                        case .success(let downloadURL):
                            UserDefaults.standard.setValue(downloadURL, forKey: "profilePictureURL")
                            print("Profile picture URL")
                            print(downloadURL)
                        case .failure(let error):
                            print("Storage manager error: \(error)")
                        }
                    })
                    //self.createPetProfile(currentUser)
                    completion(true, currentUser)
                }
            })
        })
    }
}

extension UITextView {
//      func setBottomBorder() {
//        self.borderStyle = .none
//        self.layer.backgroundColor = UIColor.white.cgColor
//
//        self.layer.masksToBounds = false
//        self.layer.shadowColor = UIColor.gray.cgColor
//        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
//        self.layer.shadowOpacity = 1.0
//        self.layer.shadowRadius = 0.0
//      }
    func setStyling() {
        self.textColor = .lightGray
        self.text = "Enter description (Optional)"
        self.layer.backgroundColor = UIColor.white.cgColor

        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

//spinner.show(in: view)
//        let email = UserDefaults.standard.value(forKey: "email") as! String
//        let password = UserDefaults.standard.value(forKey: "password") as! String
//        let name = UserDefaults.standard.value(forKey: "name") as! String
//        let description = UserDefaults.standard.value(forKey: "description") as! String
//
//        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
//            guard authResult != nil, error == nil else {
//                self.alertUserRegisterError(message: "User with this email already exists.")
//                //self.spinner.dismiss()
//                return
//            }
//
//            DispatchQueue.main.async {
//                //self.spinner.dismiss()
//            }
//
//            let currentUser = User(name: name, email: email, description: description)
//            DatabaseManager.shared.insertUser(with: currentUser, completion: { success in
//                if success {
//                    // upload profile picture
//                    guard let profilePicture = self.getSavedProfilePicture(named: "profilePicture"), let profilePicData = profilePicture.pngData() else {
//                        print("aici e problema???")
//                        return
//                    }
//
//                    StorageManager.shared.uploadProfilePicture(with: profilePicData, fileName: currentUser.profilePictureFileName, currentUserEmail: currentUser.safeEmail, completion: { result in
//                        switch result {
//                        case .success(let downloadURL):
//                            UserDefaults.standard.setValue(downloadURL, forKey: "profilePictureURL")
//                            print("Profile picture URL")
//                            print(downloadURL)
//                        case .failure(let error):
//                            print("Storage manager error: \(error)")
//                        }
//                    })
//                    self.createPetProfile(currentUser)
//                }
//            })
//        })


//        if let name = UserDefaults.standard.value(forKey: "name") as? String,
//           let emailAddress = UserDefaults.standard.value(forKey: "email") as? String,
//           let description = UserDefaults.standard.value(forKey: "description") as? String,
//           let pictureUrl = UserDefaults.standard.value(forKey: "pictureUrl") as? String {
//            let currentUser = User(name: name, email: emailAddress, description: description)
//            DatabaseManager.shared.insertUser(with: currentUser, completion: { success in
//                    if success {
//                        guard let url = URL(string: pictureUrl) else {
//                            return
//                        }
//
//                        print("Downloading data from facebook image")
//
//                        URLSession.shared.dataTask(with: url, completionHandler: { data, _,_ in
//                            guard let data = data else {
//                                print("Failed to get data from facebook")
//                                return
//                            }
//
//                            print("got data from FB, uploading...")
//
//                            // upload iamge
//                            let filename = currentUser.profilePictureFileName
//                            StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, currentUserEmail: currentUser.safeEmail, completion: { result in
//                                switch result {
//                                case .success(let downloadUrl):
//                                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
//                                    print(downloadUrl)
//                                case .failure(let error):
//                                    print("Storage maanger error: \(error)")
//                                }
//                            })
//                        }).resume()
//                    }
//                })
//            if let token = AccessToken.current,
//                !token.isExpired {
//                let token = token.tokenString
//
//                let credential = FacebookAuthProvider.credential(withAccessToken: token)
//                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
//                    guard let strongSelf = self else {
//                        return
//                    }
//
//                    guard authResult != nil, error == nil else {
//                        if let error = error {
//                            print("Facebook credential login failed, MFA may be needed - \(error)")
//                        }
//                        return
//                    }
//
//                    print("Successfully logged user in")
//                    strongSelf.createPetProfile(currentUser)
//                })
//            }
//        }

//FOR OPTIONAL DETAILS
//if let gender = UserDefaults.standard.value(forKey: "gender") as? String {
//    petProfile.gender = gender
//}
//
//if let age = UserDefaults.standard.value(forKey: "age") as? String {
//    petProfile.age = age
//}
//
//if let size = UserDefaults.standard.value(forKey: "size") as? String {
//    petProfile.size = size
//}
//
//if let adoptionType = UserDefaults.standard.value(forKey: "adoptionType") as? String {
//    petProfile.adoptionType = adoptionType
//}
//
//if let neutered = (UserDefaults.standard.value(forKey: "neutered") as? String == "Yes") ? true : false {
//    petProfile.neutered = neutered
//}
//
//if let trained = (UserDefaults.standard.value(forKey: "trained") as? String == "Yes") ? true : false {
//    petProfile.trained = trained
//}
//
//if let kidFriendly = (UserDefaults.standard.value(forKey: "kidFriendly") as? String == "Yes") ? true : false {
//    petProfile.kidFriendly = kidFriendly
//}
//
//if let environment = UserDefaults.standard.value(forKey: "petLocation") as? String {
//    petProfile.environment = environment
//}

//CREATE PET PROFILE
//            DatabaseManager.shared.insertProfile(with: petProfile, with: currentUser) { success in
//                if success {
//                    print("success - added user")
//                    print("now uploading photos")
//                    //upload photo
//                    for photo in self.photos {
//                        print("Restoration identifier")
//                        print(photo.restorationIdentifier!)
//                        if (!photo.restorationIdentifier!.hasPrefix("default")) {
//                            guard let image = photo.image, let data = image.pngData() else {
//                                return
//                            }
//
//                            let fileName = photo.restorationIdentifier!
//                            print("FILENAME:")
//                            print(fileName)
//                            StorageManager.shared.uploadPhoto(with: data, fileName: fileName, petProfileId: uuid, currentUserEmail: currentUser.safeEmail, completion: { result in
//                                switch result {
//                                case .success(let downloadURL):
//                                    UserDefaults.standard.setValue(downloadURL, forKey: "\(fileName)URL")
//                                    print("-------------")
//                                    print(downloadURL)
//                                case .failure(let error):
//                                    print("Storage manager error: \(error)")
//                                }
//                            })
//                        }
//                    }
//                    print("Finish Register Segue")
//                    self.performSegue(withIdentifier: K.finishRegisterSegue, sender: self)
//                }
//            }
