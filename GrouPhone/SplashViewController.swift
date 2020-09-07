//
//  SplashViewController.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/29.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    var labelx:UILabel?
    var animation:Animation?
    var pngAnimation:PngAnimation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let width: CGFloat = 300
        let height: CGFloat = 300
        let size = view.frame.size
        let animationFrame = CGRect(
        x: size.width/2 - width/2,
        y: size.height/2 - height/2,
        width: width, height: height)

        debugPrint("view.frame.width : \(view.frame.size.width)")
        debugPrint("view.frame.height : \(view.frame.size.height)")
        pngAnimation = PngAnimation(frame: animationFrame, format: "dog-%d.png", frameNumber: 31, frameRate: 10)
//        pngAnimation = PngAnimation(frame: animationFrame, format: "elephant-%d.png", frameNumber: 18, frameRate: 10)
        self.view.addSubview(pngAnimation!)
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
