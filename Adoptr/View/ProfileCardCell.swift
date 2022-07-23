//
//  ProfileCardCell.swift
//  Adoptr
//
//  Created by Alexandra Negru on 03/05/2022.
//

import UIKit
import VerticalCardSwiper

class ProfileCardCell: CardCell {
    @IBOutlet weak var petNameAgeLabel: UILabel!
    @IBOutlet weak var petTypeLabel: UILabel!
    @IBOutlet weak var petPhoto: UIImageView!
    @IBOutlet weak var petTypePicture: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    
    var currentlyShownPetOwner: [String:String] = [:]
    var currentlyShownPetProfile: PetProfile = PetProfile(typeProfile: "", name: "", description: "", gender: "", age: "", adoptionType: "", size: "", neutered: true, trained: true, kidFriendly: true, environment: "", owner: [:], uuid: "")
    
    
//    var delegate: ButtonClick?

    public func setRandomBackgroundColor() {
//        let randomRed: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
//        let randomGreen: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
//        let randomBlue: CGFloat = CGFloat(arc4random()) / CGFloat(UInt32.max)
        //self.backgroundColor = UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        self.backgroundColor = UIColor(named: K.accentColor)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    override func layoutSubviews() {

        self.layer.cornerRadius = 12
        petPhoto.layer.cornerRadius = 12
        petNameAgeLabel.textColor = UIColor.white
        petTypeLabel.textColor = UIColor.white
        super.layoutSubviews()
    }
    
//    @IBAction func petPhotoClicked(_ sender: UIButton) {
//        delegate?.didClickPetPhoto()
//    }
//
//    @IBAction func messageClicked(_ sender: UIButton) {
//        delegate?.didClickMessage()
//    }
//
//    @IBAction func addToFavoritesClicked(_ sender: UIButton) {
//        delegate?.didClickAddToFavorites()
//    }

}

//protocol ButtonClick {
//    // protocol definition goes here
//    func didClickPetPhoto()
//    func didClickMessage()
//    func didClickAddToFavorites()
//}
