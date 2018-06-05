//
//  DVCarouselCell.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit

class DVCarouselCell: UICollectionViewCell {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    public lazy var labels : UILabel =  {
        let lab = UILabel.init(frame: CGRect.init(x: 10, y: 10, width: 10, height: 10))
        return lab;
        lab.backgroundColor = UIColor.red
    }()
    
    public lazy var bkImage : UIImageView = {
      let imageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 100, height: 100))
       return  imageView
    }()
    
    override func draw(_ rect: CGRect) {
        self.setUI()
    }
    
    @objc private func setUI(){
        self.addSubview(self.labels)
        self.addSubview(self.bkImage)
    }
}
