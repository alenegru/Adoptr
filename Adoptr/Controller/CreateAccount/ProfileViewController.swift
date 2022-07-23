//
//  ProfileViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 20/09/2021.
//

import UIKit

class ProfileViewController: UIViewController {
    @IBOutlet weak var buttonStackView: UIStackView!
    
    let adopterButton: CustomButton = {
        let adopterButton = CustomButton(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        adopterButton.configure(with: CustomButtonModel(
            primaryText: "Adopt a pet",
                                    secondaryText: "Adopt a pet", imageView: UIImage(named: "dog-in-box")!, labelColor: UIColor(named: K.textColor)!,
                                    backgroundColor: UIColor(ciColor: .white)))
        adopterButton.translatesAutoresizingMaskIntoConstraints = false
        adopterButton.tag = 1
        adopterButton.addTarget(self, action:#selector(chooseProfile(_:)), for: .touchUpInside)
        return adopterButton
    }()
    
    let giveForAdoptionButton: CustomButton = {
        let giveForAdoptionButton = CustomButton(frame: CGRect(x: 0, y: 300, width: 200, height: 200))
//        giveForAdoptionButton.configure(with: CustomButtonModel(
//            primaryText: "Give a pet for adoption",
//            secondaryText: "Give a pet for adoption", imageView: UIImage(named: "pet-care")!, labelColor: UIColor(ciColor: .white),
//                                            backgroundColor: UIColor(named: K.accentColor)!))
        
        giveForAdoptionButton.configure(with: CustomButtonModel(
            primaryText: "Give a pet for adoption",
            secondaryText: "Give a pet for adoption", imageView: UIImage(named: "pet-care")!, labelColor: UIColor(named: K.textColor)!,
                                            backgroundColor: UIColor(ciColor: .white)))
        
        giveForAdoptionButton.translatesAutoresizingMaskIntoConstraints = false
        giveForAdoptionButton.tag = 2
        giveForAdoptionButton.addTarget(self, action:#selector(chooseProfile(_:)), for: .touchUpInside)
        return giveForAdoptionButton
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ADOPTER BUTTON
        view.addSubview(adopterButton)
        
        //GIVE FOR ADOPTION BUTTON
        view.addSubview(giveForAdoptionButton)
        
        //Add buttons to stack view
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fillEqually
        buttonStackView.spacing = 80.0
        
        buttonStackView.addArrangedSubview(adopterButton)
        buttonStackView.addArrangedSubview(giveForAdoptionButton)
        view.backgroundColor = UIColor(named: K.accentColor)!
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = UIColor(ciColor: .white)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UIColor(named: K.accentColor)
    }
    
    @objc func chooseProfile(_ sender: CustomButton){
        self.navigationController?.navigationBar.tintColor = UIColor(named: K.accentColor)
        switch sender.tag {
           case 1:
            //Adopter button
            if (UserDefaults.standard.value(forKey: "facebookLogin") as! Bool) {
                UserDefaults.standard.setValue(false, forKey: "facebookLogin")
                createUserWithFacebook() { success, currentUser in
                    if (success) {
                        self.performSegue(withIdentifier: K.createAdopterAccountSegue, sender: self)
                    }
                }
            } else {
                createUserWithEmail() { success, currentUser in
                    if (success) {
                        self.performSegue(withIdentifier: K.createAdopterAccountSegue, sender: self)
                        UserDefaults.standard.setValue(false, forKey: "petAdoption")
                    }
                }
            }
            break;
           case 2:
            //Give for adoption button
            self.performSegue(withIdentifier: K.giveForAdoptionSegue, sender: self)
            break;
           default: ()
                   break;
        }
    }
}
