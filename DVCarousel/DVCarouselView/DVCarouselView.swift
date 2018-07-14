//
//  DVCarouselView.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit
import Kingfisher

protocol DVCarouselViewDelegate:NSObjectProtocol {
    func carouselViewWithTapHandle()
}

public class DVCarouselView: UIView {
    
    weak var delegate : DVCarouselViewDelegate?
    
    private lazy var singleTapGesture : UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.tapHandle))
        return tap
    }()
    
    
    public lazy var backgroundImg : UIImageView = {
        let imae = UIImageView.init(frame: self.bounds)
        imae.isUserInteractionEnabled = false
        imae.contentMode = .scaleAspectFill
        imae.clipsToBounds = true
        return imae
    }()
    
    public override func setNeedsLayout() {
        self.addSubview(self.backgroundImg)
        self.addGestureRecognizer(self.singleTapGesture)
    }
    
    public override func draw(_ layer: CALayer, in ctx: CGContext) {
        self.isUserInteractionEnabled = true
    }
    
    @objc private func tapHandle(sender:UIGestureRecognizer){
        self.delegate?.carouselViewWithTapHandle()
    }
    
    public func setupUI(imageName: String?, imageUrl: String?, placeholderImage: UIImage?) {
        if imageName != nil {
            self.backgroundImg.image = UIImage(named: imageName!)
        } else if imageUrl != nil {
            self.backgroundImg.kf.setImage(with: URL(string: imageUrl!), placeholder: placeholderImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
    }

}

extension DVCarouselDotView{
    
   
}
