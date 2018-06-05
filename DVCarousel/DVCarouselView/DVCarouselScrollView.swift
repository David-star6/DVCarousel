//
//  DVCarouselScrollView.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit

open class DVCarouselScrollView: UIView ,UIScrollViewDelegate {

    // 本地图片
    @objc public var localizationImageNameArray : [String]?{
        didSet{
            self.sourceArray = localizationImageNameArray as [AnyObject]?
        }
    }
    // 网络图片
    @objc public var imageUrlStringArray : [String]?{
        didSet{
            self.sourceArray = imageUrlStringArray as [AnyObject]?
        }
    }
    // 预加载图片
    @objc public var placeholderImage : UIImage?
    // 存放图片的数组
    @objc public var imageViewArray : [UIImageView]? = [UIImageView]()
    // 轮播定时器
    @objc private var scrollTimer : Timer?
    //传入的资源
    @objc private var sourceArray : [AnyObject]? {
        didSet{
          self.layoutIfNeeded()
        }
    }
    // 从第几个开始转
    @objc private var current = 0{
        didSet{
            
        }
    }
    // 自动滑动
    @objc public var autoScroll = true{
        didSet{
            if autoScroll {
                self.setupTimer()
            }
        }
    }
    //轮播间隔时间
    @objc public var ScrollTimeInterval : TimeInterval = 5.0{
        didSet{
            self.cleanTimer()
            ScrollTimeInterval > 0 ? self.setupTimer() : nil
        }
    }
    
    private lazy var dotView : DVCarouselDotView = {
        let dotView = DVCarouselDotView.init(frame: CGRect.init(x: 0, y: self.frame.height - 10, width: self.frame.width, height: 10))
        return dotView
    }()
    
    /// 传入的资源总数
    private var sourceCount:Int{
        if self.localizationImageNameArray != nil{
            return (self.localizationImageNameArray?.count)!
        } else if self.imageUrlStringArray != nil{
            return (self.imageUrlStringArray?.count)!
        }
        return 0
    }

    private lazy var scrollView : UIScrollView = {
       let scrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        scrollView.contentSize = CGSize.init(width:3 * self.frame.width, height: self.frame.height)
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    open override func layoutSubviews() {
        self.dotView.setDotNumber(number: self.getShowCount())
        self.addSubview(self.scrollView)
        self.addSubview(self.dotView)
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.creatScrollView()
        self.loadDynamic()
    }
}


// MARK: - 初始化方法
extension DVCarouselScrollView{
    
    @objc open class func alloc(frame:CGRect)-> DVCarouselScrollView{
        let carouselView = DVCarouselScrollView(frame:frame)
        carouselView.setUI(localImageArray: nil, imageUrlArray: nil, imageViewArray: nil, loadImage: nil)
        return carouselView
    }
    
    /*设置控件的图片类型*/
    @objc private func setUI(localImageArray: [String]?,imageUrlArray:[String]?,imageViewArray:[UIImageView]?,loadImage:UIImage?){
        self.localizationImageNameArray = localImageArray
        self.imageUrlStringArray = imageUrlArray
        self.placeholderImage = loadImage
    }
}


// MARK: - scrollView
extension DVCarouselScrollView {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.cleanTimer()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setupTimer), object: "setupTimer")
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x <= 0){
            self.scrollTimer != nil ? self.onPageRight() :  self.onPageLeft()
        } else if (scrollView.contentOffset.x >= scrollView.frame.width * 2){
            self.scrollTimer != nil ? self.onPageLeft() : self.onPageRight()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.perform(#selector(setupTimer), with: "setupTimer", afterDelay: self.ScrollTimeInterval)
    }

}

// MARK: -- 滑动时间
extension DVCarouselScrollView{
    @objc public func setupTimer(){
        if self.scrollTimer != nil {return}
        self.scrollTimer = Timer.scheduledTimer(timeInterval: self.ScrollTimeInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(self.scrollTimer!, forMode: .commonModes)
    }
    
    @objc public func cleanTimer(){
        self.scrollTimer?.invalidate()
        self.scrollTimer = nil
    }
    
    @objc private func automaticScroll(){
          self.scrollView.contentOffset = CGPoint.init(x: 0, y: 0)
    }
}

// MARK: -- 滑動视图
extension DVCarouselScrollView{
    
    @objc private func loadDynamic(){
        for i in 0...2{
//            let index = ( -i - 1 + self.currentIndex() + self.getShowCount()) % self.getShowCount()
//            let index = ( -i + 1 + self.currentIndex() + self.getShowCount()) % self.getShowCount()
            let index = ( i - 1 + self.currentIndex() + self.getShowCount()) % self.getShowCount()
            let imgView =  self.imageViewArray![i]
            imgView.image = self.getImageWithArray(index: index)
        }
        self.scrollTimer != nil  ? self.scrollView.setContentOffset(CGPoint.init(x: self.frame.width, y: 0), animated: true) : self.scrollView.setContentOffset(CGPoint.init(x: self.frame.width, y: 0), animated: false)
        self.dotView.setSelectIndex(index: self.currentIndex())
    }
    
    @objc private func getImageWithArray(index:Int)-> UIImage {
        var img : UIImage?
        if self.localizationImageNameArray != nil {
            img =  UIImage.init(named: self.localizationImageNameArray![index])
        } else if self.imageUrlStringArray != nil {
            img =  UIImage.init(named: self.imageUrlStringArray![index])
        }
        return img!
    }
    
    @objc private func creatScrollView(){
        for i in 0...2 {
            let x = CGFloat(i) * self.frame.width
            let width = self.frame.width
            let height = self.frame.height
            let imageView = DVCarouselView.init(frame: CGRect.init(x: x, y: 0, width: width, height: height))
            imageView.backgroundColor = UIColor.blue
            imageView.isUserInteractionEnabled = false
            self.scrollView.addSubview(imageView)
            self.imageViewArray?.append(imageView)
        }
    }
    
    @objc private func onPageLeft(){
        self.current = ( -1 + self.current + self.getShowCount()) % self.getShowCount();
        self.loadDynamic()
    }
    
    @objc private func onPageRight(){
        self.current = ( 1 + self.current + self.getShowCount()) % self.getShowCount();
        self.loadDynamic()
    }
    
    @objc private func getShowCount() -> Int{
        return self.sourceCount
    }
    
    @objc private func currentIndex() -> Int{
        return current
    }
}
