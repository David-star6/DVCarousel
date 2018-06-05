//
//  DVCarouselDotView.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit

open class DVCarouselDotView: UIView {

    lazy private var pageControl : UIPageControl={
       let page = UIPageControl.init()
        page.frame = self.bounds
        page.numberOfPages = 3
        return page
    }()
    
    override open func draw(_ rect: CGRect) {
        self.addSubview(self.pageControl)
    }
    
}


extension DVCarouselDotView{
    @objc public func setSelectIndex(index:Int){
        self.pageControl.currentPage = index
    }
    
    @objc public func setDotNumber(number:Int){
        self.pageControl.numberOfPages = number
    }
}
