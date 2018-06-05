//
//  ViewController.swift
//  DVCarousel
//
//  Created by jacob on 2018/5/23.
//  Copyright © 2018年 david. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let view = DVCarouselScrollView.alloc(frame: CGRect.init(x: 0, y: 0, width: 375, height: 300))
        view.autoScroll = true
        view.ScrollTimeInterval = 3
        view.localizationImageNameArray = ["sample","22","3","22",]
        self.view.addSubview(view)
        // 看到自己写的这种堆功能的乱代码，我也是笑了。
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


