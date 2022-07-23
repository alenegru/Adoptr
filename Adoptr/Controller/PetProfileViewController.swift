//
//  PetProfileViewController.swift
//  Adoptr
//
//  Created by Alexandra Negru on 07/05/2022.
//

import UIKit

class PetProfileViewController: UIViewController {
    @IBOutlet weak var photosScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var typeProfilePic: UIImageView!
    @IBOutlet weak var petNameLabel: UILabel!
    @IBOutlet weak var genderAgeLabel: UILabel!
    @IBOutlet weak var environmentField: UITextField!
    @IBOutlet weak var sizeField: UITextField!
    @IBOutlet weak var ownerField: UITextField!
    @IBOutlet weak var adoptionTypeLabel: UILabel!
    @IBOutlet weak var trainedField: UITextField!
    @IBOutlet weak var neuteredField: UITextField!
    @IBOutlet weak var kidFriendlyField: UITextField!
    @IBOutlet weak var descriptionView: UITextView!
    
    //first_picture.png
    //second_picture.png
    //third_picture.png
    //fourth_picture.png
    
    var photos: [String] = []
    var frame = CGRect.zero
    var model: PetProfile?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let downloadURLs = model?.photosDownloadURLs {
            for downloadURL in downloadURLs {
                photos.append(downloadURL.first!.value as! String)
            }
        }
        
        pageControl.numberOfPages = photos.count
        setupScreens()
        
        guard let pet = model else {
            return
        }
        
        descriptionView.setStyling()
        descriptionView.text = (pet.description == "") ? "No description available" : pet.description
        typeProfilePic.image = UIImage(named: pet.typeProfile)
        petNameLabel.text = pet.name
        genderAgeLabel.text = "\(pet.gender), \(pet.age)"
        environmentField.text = pet.environment
        sizeField.text = pet.size
        adoptionTypeLabel.text = (pet.adoptionType == "Adopt") ? "Adopt from" : "Foster from"
        if let owner = pet.owner {
            ownerField.text = owner["name"]
        } else {
            ownerField.text = "myself"
        }
        
        trainedField.text = (pet.trained) ? "Yes" : "No"
        neuteredField.text = (pet.neutered) ? "Yes" : "No"
        kidFriendlyField.text = (pet.kidFriendly) ? "Yes" : "No"

        photosScrollView.delegate = self
    }
    
    func setupScreens() {
        for index in 0..<photos.count {
            // 1.
            frame.origin.x = photosScrollView.frame.size.width * CGFloat(index)
            frame.size = photosScrollView.frame.size
            
            // 2.
            let imgView = UIImageView(frame: frame)
            let firstPhotoURL = URL(string: photos[index])
            imgView.sd_setImage(with: firstPhotoURL, completed: nil)
            imgView.layer.cornerRadius = 5
            imgView.layer.masksToBounds = true
            imgView.contentMode = .scaleAspectFit

            self.photosScrollView.addSubview(imgView)
        }

        // 3.
        photosScrollView.contentSize = CGSize(width: (photosScrollView.frame.size.width * CGFloat(photos.count)), height: photosScrollView.frame.size.height)
        photosScrollView.delegate = self
    }

}

extension PetProfileViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageNumber = scrollView.contentOffset.x / scrollView.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
}
