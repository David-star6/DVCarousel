//
//  DVCarouselScrollView.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit

@objc protocol DVCarouselScrollViewDelegate : NSObjectProtocol  {
    @objc optional func selectCarousel(index:Int)
}

open class DVCarouselScrollView: UIView ,UIScrollViewDelegate ,DVCarouselViewDelegate {
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
    var blockselectCarousel : ((Int) -> (Void))?
    // 代理
    @objc weak var carouseDelegate :DVCarouselScrollViewDelegate?
    // 预加载图片
    @objc public var placeholderImage : UIImage?
    // 存放图片的数组
    @objc public var imageViewArray : [DVCarouselView]? = [DVCarouselView]()
    // 轮播定时器
    private var scrollTimer : Timer?
    //传入的资源
    private var sourceArray : [AnyObject]? {
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
    
    @objc open class func carousel(frame:CGRect)-> DVCarouselScrollView{
        let carouselView = DVCarouselScrollView(frame:frame)
        carouselView.setUI(localImageArray: nil, imageUrlArray: nil, imageViewArray: nil, loadImage: nil)
        return carouselView
    }
    
    @objc open class func carouselImage(localizationImageNameArray:[String]?,frame:CGRect) -> DVCarouselScrollView{
        let carouselView = DVCarouselScrollView(frame:frame)
        carouselView.setUI(localImageArray: localizationImageNameArray, imageUrlArray: nil, imageViewArray: nil, loadImage: nil)
        return carouselView
    }
    
    @objc open class func carouselImage(imageUrlStrArray:[String]?,placeholderImage:UIImage?,frame:CGRect) -> DVCarouselScrollView{
        let carouselView = DVCarouselScrollView(frame:frame)
        carouselView.setUI(localImageArray: nil, imageUrlArray: imageUrlStrArray, imageViewArray: nil, loadImage: nil)
        return carouselView
    }
    
    //设置控件的图片类型
    private func setUI(localImageArray: [String]?,imageUrlArray:[String]?,imageViewArray:[UIImageView]?,loadImage:UIImage?){
        self.localizationImageNameArray = localImageArray
        self.imageUrlStringArray = imageUrlArray
        self.placeholderImage = loadImage
    }
    
}


// MARK: - scrollView
extension DVCarouselScrollView {
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
      self.pause()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView.contentOffset.x <= 0){
            self.scrollTimer != nil ? self.onPageRight() : self.onPageLeft()
        } else if (scrollView.contentOffset.x >= scrollView.frame.width * 2){
            self.scrollTimer != nil ? self.onPageLeft() : self.onPageRight()
        }
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.delayStartTimer()
    }

}

// MARK: -- 滑动时间
extension DVCarouselScrollView{
    // 暂停
    private func pause(){
        self.cleanTimer()
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(setupTimer), object: "setupTimer")
    }
    // 延时启动
    @objc public func delayStartTimer(){
        self.perform(#selector(setupTimer), with: "setupTimer", afterDelay: self.ScrollTimeInterval)
    }
     // 滑动开始
    @objc public func setupTimer(){
        if self.scrollTimer != nil {return}
        self.scrollTimer = Timer.scheduledTimer(timeInterval: self.ScrollTimeInterval, target: self, selector: #selector(automaticScroll), userInfo: nil, repeats: true)
        RunLoop.main.add(self.scrollTimer!, forMode: .commonModes)
    }
     // 清除滑动
    public func cleanTimer(){
        self.scrollTimer?.invalidate()
        self.scrollTimer = nil
    }
     // 滑动
    @objc private func automaticScroll(){
        self.scrollWithAnimation(x: 0, animation: false)
    }
    private func scrollWithAnimation(x:CGFloat, animation:Bool){
        self.scrollView.setContentOffset(CGPoint.init(x: x, y: 0), animated: animation)
    }
}

// MARK: -- 滑動视图
extension DVCarouselScrollView{
     // 视图滚动
     private func loadDynamic(){
        for i in 0...2{
            let index = ( i - 1 + self.currentIndex() + self.getShowCount()) % self.getShowCount()
            let imgView =  self.imageViewArray![i]
            imgView.setupUI(imageName: self.localizationImageNameArray != nil ? self.localizationImageNameArray![index] : nil , imageUrl:(self.imageUrlStringArray != nil) ? (self.imageUrlStringArray)![index] : nil , placeholderImage: self.placeholderImage != nil ? self.placeholderImage : nil )
//            imgView.image = self.getImageWithArray(index: index)
        }
        self.scrollTimer != nil ? self.scrollWithAnimation(x: self.frame.width, animation: true) : self.scrollWithAnimation(x: self.frame.width, animation: false)
        self.dotView.setSelectIndex(index: self.currentIndex())
    }
    
     // 生成视图
     private func creatScrollView(){
        for i in 0...2 {
            let x = CGFloat(i) * self.frame.width
            let width = self.frame.width
            let height = self.frame.height
            let imageView = DVCarouselView.init(frame: CGRect.init(x: x, y: 0, width: width, height: height))
            imageView.delegate = self as DVCarouselViewDelegate
            self.scrollView.addSubview(imageView)
//            self.imageViewArray?.append(imageView.backgroundImg)
            self.imageViewArray?.append(imageView)
        }
    }
     // delegate 点击以后暂停
     func carouselViewWithTapHandle() {
        self.pause()
        self.delayStartTimer()
        if self.carouseDelegate != nil {
            self.carouseDelegate?.selectCarousel!(index: self.currentIndex())
        }else if(self.blockselectCarousel != nil) {
            self.blockselectCarousel!(self.currentIndex())
        }
    }

     private func onPageLeft(){
        self.current = ( -1 + self.current + self.getShowCount()) % self.getShowCount();
        self.loadDynamic()
    }
    
     private func onPageRight(){
        self.current = ( 1 + self.current + self.getShowCount()) % self.getShowCount();
        self.loadDynamic()
    }
    
     private func getShowCount() -> Int{
        return self.sourceCount
    }
    
     private func currentIndex() -> Int{
        return current
    }
}


