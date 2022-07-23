//
//  PetProfilePreviewCell.swift
//  Adoptr
//
//  Created by Alexandra Negru on 30/05/2022.
//

import UIKit

class PetProfilePreviewCell: UITableViewCell {
    @IBOutlet weak var petPicture: UIImageView!
    @IBOutlet weak var petTypePicture: UIImageView!
    @IBOutlet weak var petName: UILabel!
    @IBOutlet weak var petGenderAgeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        petPicture.makeRounded()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
