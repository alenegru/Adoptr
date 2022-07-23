//
//  StandardButton.swift
//  Adoptr
//
//  Created by Alexandra Negru on 13/08/2021.
//

import UIKit

struct StandardButtonModel {
    let label: String
    let labelColor: UIColor
    let backgroundColor: UIColor
}

final class StandardButton: UIButton {
    override func awakeFromNib() {
        super.awakeFromNib()
 
        self.layer.cornerRadius = 25.0
        self.clipsToBounds = true
        self.backgroundColor = .white
        self.setTitleColor(UIColor(named: "TextColor"), for: .normal)
        self.titleLabel?.font = UIFont(name: "Montserrat-Medium", size: 20)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
//    public let label: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 1
//        label.textAlignment = .center
////        label.textColor = UIColor(named: "TextColor")
////        label.font = UIFont(name: "Montserrat-Medium", size: 30)
//        return label
//    }()

//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        addSubview(label)
//        clipsToBounds = true
//        layer.cornerRadius = 25.0
//    }
//
//    required public init?(coder: NSCoder) {
//        super.init(coder: coder)
//    }
    
    func configure(with viewModel: StandardButtonModel) {
        self.setTitle(viewModel.label, for: .normal)
        self.setTitleColor(viewModel.labelColor, for: .normal)
        self.backgroundColor = viewModel.backgroundColor
    }
    
}
