//
//  Checkbox.swift
//  Adoptr
//
//  Created by Alexandra Negru on 04/08/2021.
//

import UIKit

class Checkbox: UIView {
    var isChecked = false
    
    let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "checkmark")
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .darkGray
        layer.cornerRadius = 5.0
        clipsToBounds = true
        addSubview(imageView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
    }
    
    public func toggle() {
        isChecked = !isChecked
        imageView.isHidden = !isChecked
    }
}
