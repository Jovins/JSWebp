//
//  JSWebpCell.swift
//  JSWebp_Example
//
//  Created by Jovins on 2021/6/10.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

class JSWebpCell: UICollectionViewCell {
    
    var imageString: String? {
        didSet {
            guard let img = self.imageString else { return }
            self.webpView.setWebpImageWithURL(URL(string: img)!) { [weak self] (image, error) in
                guard let `self` = self else { return }
                if error == nil {
                    if let img = image as? JSWebpImage {
                        self.webpView.image = img
                    }
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.addSubview(self.webpView)
        
        // 底部阴影
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.withAlphaComponent(0.2).cgColor, UIColor.black.withAlphaComponent(0.6).cgColor]
        gradientLayer.locations = [0.3, 0.6, 1.0]
        gradientLayer.startPoint = CGPoint.init(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint.init(x: 0.0, y: 1.0)
        gradientLayer.frame = CGRect.init(x: 0, y: self.frame.size.height - 100, width: self.frame.size.width, height: 100)
        self.webpView.layer.addSublayer(gradientLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.webpView.frame = self.bounds
    }
    
    // MARK: - Lazy
    private lazy var webpView: JSWebpImageView = {
        let view = JSWebpImageView()
        view.backgroundColor = UIColor.random()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
}
