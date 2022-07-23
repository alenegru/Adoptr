//
//  TypeAnimalCell.swift
//  Adoptr
//
//  Created by Alexandra Negru on 15/04/2022.
//

import UIKit

class TypeAnimalCell: UITableViewCell {
    @IBOutlet weak var animalView: UIView!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var animalImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
