//
//  PhotosViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 15/04/2022.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GeoFire
import CoreML
import Vision

class PhotosViewController: UIViewController {
    @IBOutlet weak var firstPhoto: UIImageView!
    @IBOutlet weak var secondPhoto: UIImageView!
    @IBOutlet weak var thirdPhoto: UIImageView!
    @IBOutlet weak var fourthPhoto: UIImageView!
    @IBOutlet weak var continueButton: StandardButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let imagePredictor = ImagePredictor()
    
    
    var photos: [UIImageView] = []
    var typeOfAnimal: String = ""
    
    var currentChosenPhoto: UIImageView = UIImageView()
    //var currentUser: User = User(name: "", email: "", description: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.hidesWhenStopped = true
        
        firstPhoto.isUserInteractionEnabled = true
        secondPhoto.isUserInteractionEnabled = true
        thirdPhoto.isUserInteractionEnabled = true
        fourthPhoto.isUserInteractionEnabled = true
        
        firstPhoto.restorationIdentifier = "default_first_picture.png"
        secondPhoto.restorationIdentifier = "default_second_picture.png"
        thirdPhoto.restorationIdentifier = "default_third_picture.png"
        fourthPhoto.restorationIdentifier = "default_fourth_picture.png"
        
        let gesture1 = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoto(_:)))
        let gesture2 = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoto(_:)))
        let gesture3 = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoto(_:)))
        let gesture4 = UITapGestureRecognizer(target: self, action: #selector(self.didTapPhoto(_:)))
        
        firstPhoto.addGestureRecognizer(gesture1)
        secondPhoto.addGestureRecognizer(gesture2)
        thirdPhoto.addGestureRecognizer(gesture3)
        fourthPhoto.addGestureRecognizer(gesture4)
        
        continueButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        
        photos.append(firstPhoto)
        photos.append(secondPhoto)
        photos.append(thirdPhoto)
        photos.append(fourthPhoto)

    }
    
    @objc func didTapPhoto(_ recognizer: UITapGestureRecognizer) {
        guard let photoView = recognizer.view as? UIImageView else { return }
        currentChosenPhoto = photoView
        presentPhotoActionSheet()
    }
    
    func completeRegistration() {
        var isAtLeastOnePhotoAdded = false
        for photo in self.photos {
            if (!photo.restorationIdentifier!.hasPrefix("default")) {
                isAtLeastOnePhotoAdded = true
            }
        }
        if (isAtLeastOnePhotoAdded) {
            activityIndicator.startAnimating()
            if FirebaseAuth.Auth.auth().currentUser != nil ||
                AccessToken.current != nil {
                guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String,
                      let myName = UserDefaults.standard.value(forKey: "name") as? String else {
                    return
                }
                let user = User(name: myName, email: myEmail)
                createPetProfile(with: user)
            } else if (UserDefaults.standard.value(forKey: "facebookLogin") as! Bool) {
                UserDefaults.standard.setValue(false, forKey: "facebookLogin")
                createUserWithFacebookLogin()
            } else {
                createUserWithEmailLogin()
            }
        } else {
            alertUserToAddAtLeastOnePhoto()
        }
    }
    
    func createUserWithFacebookLogin() {
        createUserWithFacebook() { success, currentUser in
            if (success) {
                self.createPetProfile(with: currentUser)
            }
        }
    }
    
    func createUserWithEmailLogin() {
        createUserWithEmail() { success, currentUser in
            if (success) {
                self.createPetProfile(with: currentUser)
            }
        }
    }
    
    func createPetProfile(with currentUser: User) {
        if let typeOfAnimalUserDef = UserDefaults.standard.value(forKey: "animalType") as? String {
            //NO CLASSIF MODEL
            typeOfAnimal = typeOfAnimalUserDef
        } else {
            //IMAGE CLASSIFICATION MODEL
            let image = self.photos.first { (photo) in
                return !photo.restorationIdentifier!.hasPrefix("default")
            }
            classifyImage((image?.image)!)
        }
        
        print(typeOfAnimal)
           
        if let petName = UserDefaults.standard.value(forKey: "pet-name") as? String,
           let petDescription = UserDefaults.standard.value(forKey: "pet-description") as? String? ?? "",
           let gender = UserDefaults.standard.value(forKey: "gender") as? String,
           let age = UserDefaults.standard.value(forKey: "age") as? String,
           let size = UserDefaults.standard.value(forKey: "size") as? String,
           let adoptionType = UserDefaults.standard.value(forKey: "adoptionType") as? String,
           let neutered = (UserDefaults.standard.value(forKey: "neutered") as? String == "Yes") ? true : false,
           let trained = (UserDefaults.standard.value(forKey: "trained") as? String == "Yes") ? true : false,
           let kidFriendly = (UserDefaults.standard.value(forKey: "kidFriendly") as? String == "Yes") ? true : false,
           let environment = UserDefaults.standard.value(forKey: "environment") as? String {
            let uuid = NSUUID().uuidString
            var petProfile = PetProfile(typeProfile: typeOfAnimal,
                                      name: petName,
                                      description: petDescription,
                                      gender: gender,
                                      age: age,
                                      adoptionType: adoptionType,
                                      size: size,
                                      neutered: neutered,
                                      trained: trained,
                                      kidFriendly: kidFriendly,
                                      environment: environment,
                                      owner:[
                                        "name": currentUser.name,
                                        "email": currentUser.safeEmail
                                      ],
                                      uuid: uuid)
            UserDefaults.standard.removeObject(forKey: "animalType")
                        
            uploadPhotos(for: currentUser, with: uuid) { result in
                switch(result) {
                case .success(let downloadURLS):
                    print(downloadURLS)
                    petProfile.photosDownloadURLs = downloadURLS
                    DatabaseManager.shared.insertProfile(with: petProfile, with: currentUser) { success in
                        if success {
                            print("success - added user")
                            print("now uploading photos")
                            //upload photo
                            print("Finish Register Segue")
                            
                            DatabaseManager.shared.saveLocationForProfile(with: uuid)
                            self.activityIndicator.stopAnimating()
                            self.performSegue(withIdentifier: K.finishRegisterSegue, sender: self)
                        }
                    }
                case .failure(let error):
                    print("error getting convo + \(error)")
                }
            }
            
        }
    }
    
    func uploadPhotos(for currentUser: User, with petProfileId: String, completion: @escaping ((Result<[[String:Any]], Error>) -> Void)) {
        var downloadURLS: [[String:Any]] = []
        self.photos.removeAll { photo in
            photo.restorationIdentifier!.hasPrefix("default")
        }
        
        for photo in self.photos {
            print("Restoration identifier")
            print(photo.restorationIdentifier!)
            guard let image = photo.image, let data = image.pngData() else {
                return
            }
            
            let fileName = photo.restorationIdentifier!
            print("FILENAME:")
            print(fileName)
            StorageManager.shared.uploadPhoto(with: data, fileName: fileName, petProfileId: petProfileId, currentUserEmail: currentUser.safeEmail, completion: { result in
                switch result {
                case .success(let downloadURL):
                    UserDefaults.standard.setValue(downloadURL, forKey: "\(fileName)URL")
                    print("-------------")
                    print(downloadURL)
                    let fileNameKey = fileName.components(separatedBy: ".")
                    let newPhoto = [
                        "\(fileNameKey[0])": "\(downloadURL)"
                    ]
                    downloadURLS.append(newPhoto)
                    if self.photos.last == photo {
                        completion(.success(downloadURLS))
                        print("*****************************************")
                        print(downloadURLS)
                        print("*****************************************")
                    }
                case .failure(let error):
                    print("Storage manager error: \(error)")
                }
            })
        }
    }
    
    
    @IBAction func continueButtonTapped(_ sender: StandardButton) {
        completeRegistration()
    }
    
}

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Add a photo", message: "How would you like to select a photo?", preferredStyle: .actionSheet)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        
        currentChosenPhoto.image = selectedImage
        if (currentChosenPhoto.restorationIdentifier == "default_first_picture.png") {
            currentChosenPhoto.restorationIdentifier = "first_picture.png"
        } else if (currentChosenPhoto.restorationIdentifier == "default_second_picture.png") {
            currentChosenPhoto.restorationIdentifier = "second_picture.png"
        } else if (currentChosenPhoto.restorationIdentifier == "default_third_picture.png") {
            currentChosenPhoto.restorationIdentifier = "third_picture.png"
        } else {
            currentChosenPhoto.restorationIdentifier = "fourth_picture.png"
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- Image Classification Model

extension PhotosViewController {
    // MARK: Image prediction methods
    /// Sends a photo to the Image Predictor to get a prediction of its content.
    /// - Parameter image: A photo.
    private func classifyImage(_ image: UIImage) {
        do {
            try self.imagePredictor.makePredictions(for: image,
                                                    completionHandler: imagePredictionHandler)
        } catch {
            print("Vision was unable to make a prediction...\n\n\(error.localizedDescription)")
        }
    }
    
    /// The method the Image Predictor calls when its image classifier model generates a prediction.
    /// - Parameter predictions: An array of predictions.
    /// - Tag: imagePredictionHandler
    private func imagePredictionHandler(_ predictions: [ImagePredictor.Prediction]?){
        guard let predictions = predictions else {
            print("No predictions. (Check console log.)")
            return
        }

        let formattedPredictions = formatPredictions(predictions)

        //let predictionString = formattedPredictions.joined(separator: "\n")
        for prediction in formattedPredictions {
            print(prediction.1)
        }
        
        typeOfAnimal = formattedPredictions[0].0
    }

    /// Converts a prediction's observations into human-readable strings.
    /// - Parameter observations: The classification observations from a Vision request.
    /// - Tag: formatPredictions
    private func formatPredictions(_ predictions: [ImagePredictor.Prediction]) -> [(String, String)] {
        // Vision sorts the classifications in descending confidence order.
        let topPredictions: [(String, String)] = predictions.prefix(2).map { prediction in
            var name = prediction.classification

            // For classifications with more than one name, keep the one before the first comma.
            if let firstComma = name.firstIndex(of: ",") {
                name = String(name.prefix(upTo: firstComma))
            }

            return (name, "\(name) - \(prediction.confidencePercentage)% \n")
        }

        return topPredictions
    }
}


