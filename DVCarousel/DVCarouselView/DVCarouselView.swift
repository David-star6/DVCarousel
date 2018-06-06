//
//  DVCarouselView.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit

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

}

extension DVCarouselDotView{
    
   
}
