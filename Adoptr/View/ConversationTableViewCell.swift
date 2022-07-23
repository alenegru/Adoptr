//
//  ConversationTableViewCell.swift
//  Adoptr
//
//  Created by Alexandra Negru on 30/05/2022.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var latestMessageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //profilePic.layer.borderWidth = 0.5
        profilePic.layer.masksToBounds = false
        //profilePic.layer.borderColor = UIColor.black.cgColor
        profilePic.layer.cornerRadius = profilePic.frame.height / 2
        profilePic.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
