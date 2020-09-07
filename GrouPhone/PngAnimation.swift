//
//  PngAnimation.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/28.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit

class PngAnimation: UIView {

    var animationLayer:CALayer?
    var layerframe:CGRect?
    var frameNumber:Int?
    var frameRate:Float?
    var timing = [NSNumber]()
    var images = [CGImage]()
    
    init(frame: CGRect, format:String, frameNumber:Int, frameRate:Float) {
        super.init(frame: frame)
                
        self.layerframe = CGRect(x: 0,y: 0,width: frame.width,height: frame.height)
        self.frameNumber = frameNumber
        self.frameRate = frameRate
        self.animationLayer = createAnimationLayer(format, frameNumber:frameNumber, frameRate:frameRate)
        self.layer.addSublayer(animationLayer!)

        animation()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func createAnimationLayer(_ baseformat:String, frameNumber:Int, frameRate:Float) -> CALayer {
        let animationLayer:CALayer = CALayer()
        animationLayer.frame = self.layerframe!

        for i in 0...frameNumber  {
          let name =  String(format: baseformat, i)
            debugPrint("pngname:" + name)
            if let image = UIImage(named: name)?.cgImage {
                images.append(image)
                let t = NSNumber(value: Float(i) / Float(frameNumber))
                debugPrint("t : \(t)")
                timing.append(t)
            }
            
        }

        return animationLayer;
    }
    
    func animation() {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "contents"
        animation.duration = CFTimeInterval(Float(self.frameNumber!)/self.frameRate!)
        animation.isRemovedOnCompletion = false

        animation.keyTimes = timing
        animation.values = images
        animation.calculationMode = CAAnimationCalculationMode.discrete
        animation.repeatCount = 1
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.delegate = self
        
                
        self.animationLayer?.add(animation, forKey: "contents")

    }
}

extension PngAnimation: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        debugPrint("animationDidStop()->")
        //アニメーションが終わったらimageViewを消す
//        self.removeFromSuperview()
        
        debugPrint("<-animationDidStop()")
    }
}
