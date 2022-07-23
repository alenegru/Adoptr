//
//  CustomButton.swift
//  Adoptr
//
//  Created by Alexandra Negru on 27/02/2022.
//

import UIKit

struct CustomButtonModel {
    let primaryText: String
    let secondaryText: String
    let imageView: UIImage
    let labelColor: UIColor
    let backgroundColor: UIColor
//    let secondaryImage: UIImage
}

final class CustomButton: UIButton {
    private let primaryLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = UIColor(named: K.accentColor)
        label.font = UIFont(name: K.fontRegular, size: CGFloat(K.fontSizeTitle))
        return label
    }()
    
    private let image: UIImageView = {
       let image = UIImageView()
        image.tintColor = .black
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(primaryLabel)
        addSubview(image)
        clipsToBounds = true
        layer.cornerRadius = 45
        layer.borderWidth = 2
        layer.borderColor = UIColor(ciColor: .white).cgColor
        layer.shadowColor = UIColor(ciColor: .white).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 1.0
        layer.shadowRadius = 10.0
        layer.masksToBounds = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        primaryLabel.frame = CGRect(x: 5, y: 0, width: frame.size.width-10, height: frame.size.height/2)
        image.frame = CGRect(x: 5, y: frame.size.height/2 - 30, width: frame.size.width - 10, height: frame.size.height/2)
    }
    
    func configure(with viewModel: CustomButtonModel) {
        primaryLabel.text = viewModel.primaryText
        primaryLabel.textColor = viewModel.labelColor
        image.image = viewModel.imageView
        image.tintColor = UIColor(ciColor: .white)
        backgroundColor = viewModel.backgroundColor
    }
}
