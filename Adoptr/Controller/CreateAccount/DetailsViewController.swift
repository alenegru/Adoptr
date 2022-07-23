//
//  DetailsViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 27/04/2022.
//

import UIKit

class DetailsViewController: UIViewController {
    @IBOutlet weak var genderControl: UISegmentedControl!
    @IBOutlet weak var ageControl: UISegmentedControl!
    @IBOutlet weak var adoptionTypeControl: UISegmentedControl!
    @IBOutlet weak var sizeControl: UISegmentedControl!
    @IBOutlet weak var neuteredControl: UISegmentedControl!
    @IBOutlet weak var trainedControl: UISegmentedControl!
    @IBOutlet weak var kidFriendlyControl: UISegmentedControl!
    @IBOutlet weak var locationControl: UISegmentedControl!
    @IBOutlet weak var continueButton: StandardButton!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    
    var gender: String = "Male"
    var age: String = "Baby"
    var adoptionType: String = "Adopt"
    var size: String = "Small"
    var neutered: String = "Yes"
    var trained: String = "Yes"
    var kidFriendly: String = "Yes"
    var environment: String = "Indoor"
    
//    var gender: String? = nil
//    var age: String? = nil
//    var adoptionType: String? = nil
//    var size: String? = nil
//    var neutered: String? = nil
//    var trained: String? = nil
//    var kidFriendly: String? = nil
//    var environment: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        skipButton.title = ""
        continueButton.setStylingForContinueButton(backgroundColor: UIColor(named: K.accentColor)!,borderColor: UIColor(named: K.accentColor)!, titleColor: UIColor.white)
        
    }
    
    @IBAction func genderIndexChanged(_ sender: UISegmentedControl) {
        switch genderControl.selectedSegmentIndex
        {
        case 0:
            gender = "Male"
        case 1:
            gender = "Female"
        case 2:
            gender = "Multiple"
        default:
            break
        }
    }
    
    @IBAction func ageIndexChanged(_ sender: UISegmentedControl) {
        switch ageControl.selectedSegmentIndex
        {
        case 0:
            age = "Baby"
        case 1:
            age = "Junior"
        case 2:
            age = "Adult"
        case 3:
            age = "Senior"
        default:
            break
        }
    }
    
    @IBAction func adoptionTypeIndexChanged(_ sender: UISegmentedControl) {
        switch adoptionTypeControl.selectedSegmentIndex
        {
        case 0:
            adoptionType = "Adopt"
        case 1:
            adoptionType = "Foster"
        default:
            break
        }
    }
    
    @IBAction func sizeIndexChanged(_ sender: UISegmentedControl) {
        switch sizeControl.selectedSegmentIndex
        {
        case 0:
            size = "Small"
        case 1:
            size = "Medium"
        case 2:
            size = "Large"
        default:
            break
        }
    }
    
    @IBAction func neuteredIndexChanged(_ sender: UISegmentedControl) {
        switch neuteredControl.selectedSegmentIndex
        {
        case 0:
            neutered = "Yes"
        case 1:
            neutered = "No"
        default:
            break
        }
    }
    
    @IBAction func trainedIndexChanged(_ sender: UISegmentedControl) {
        switch trainedControl.selectedSegmentIndex
        {
        case 0:
            trained = "Yes"
        case 1:
            trained = "No"
        default:
            break
        }
    }
    
    @IBAction func kidFriendlyIndexChanged(_ sender: UISegmentedControl) {
        switch kidFriendlyControl.selectedSegmentIndex
        {
        case 0:
            kidFriendly = "Yes"
        case 1:
            kidFriendly = "No"
        default:
            break
        }
    }
    
    @IBAction func locationIndexChanged(_ sender: UISegmentedControl) {
        print("Environment changed")
        switch locationControl.selectedSegmentIndex
        {
        case 0:
            environment = "Indoor"
        case 1:
            environment = "Outdoor"
        case 2:
            environment = "Both"
        default:
            break
        }
    }
    
    @IBAction func continueButtonPressed(_ sender: StandardButton) {
//        if let gender = self.gender,
//           let age = self.age,
//           let adoptionType = self.adoptionType,
//           let size = self.size,
//           let neutered = self.neutered,
//           let trained = self.trained,
//           let kidFriendly = self.kidFriendly,
//           let environment = self.environment {
        UserDefaults.standard.setValue(gender, forKey: "gender")
        UserDefaults.standard.setValue(age, forKey: "age")
        UserDefaults.standard.setValue(adoptionType, forKey: "adoptionType")
        UserDefaults.standard.setValue(size, forKey: "size")
        UserDefaults.standard.setValue(neutered, forKey: "neutered")
        UserDefaults.standard.setValue(trained, forKey: "trained")
        UserDefaults.standard.setValue(kidFriendly, forKey: "kidFriendly")
        UserDefaults.standard.setValue(environment, forKey: "environment")
//        }
        
        self.performSegue(withIdentifier: K.saveDetailsSegue, sender: self)
    }
    
    
    @IBAction func skipButtonPressed(_ sender: UIBarButtonItem) {
        let prefs = UserDefaults.standard
        prefs.removeObject(forKey:"gender")
        prefs.removeObject(forKey:"age")
        prefs.removeObject(forKey:"adoptionType")
        prefs.removeObject(forKey:"size")
        prefs.removeObject(forKey:"neutered")
        prefs.removeObject(forKey:"trained")
        prefs.removeObject(forKey:"kidFriendly")
        prefs.removeObject(forKey:"environment")
        
        self.performSegue(withIdentifier: K.saveDetailsSegue, sender: self)
    }
    

}
