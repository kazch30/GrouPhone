//
//  Animation.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/27.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit

class Animation: UIView {

    var path: UIBezierPath?
    var shapeLayer: CAShapeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .blue

//        makeShapeLayer()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func makeShapeLayer() {
        self.makeTriangle()

        shapeLayer = CAShapeLayer()
        shapeLayer?.path = path?.cgPath
        shapeLayer?.lineWidth = 3.0

        layer.mask = shapeLayer
        animateLayer()
    }

    func makeTriangle() {
        path = UIBezierPath()
        path?.move(to: CGPoint(x: self.frame.width/10, y: 0.0))
        path?.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height / 10))
        path?.addLine(to: CGPoint(x: self.frame.size.width / 10, y: self.frame.size.height / 10))
        path?.close()
    }

    func animateLayer() {

        let keyAnimation = CAKeyframeAnimation(keyPath: #keyPath(CALayer.position))
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: 74, y: 200),
                      control1: CGPoint(x: 120, y: 200),
                      control2: CGPoint(x: 120, y: 74))
        path.addCurve(to: CGPoint(x: 120, y: 200),
                      control1: CGPoint(x: 366, y: 200),
                      control2: CGPoint(x: 366, y: 74))
        keyAnimation.path = path
        keyAnimation.duration = 3
        keyAnimation.delegate = self

        shapeLayer?.add(keyAnimation, forKey: nil)
    }
    
    func BasicAnimation() {
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.duration = 2.0
        animation.fromValue = 0.0
        animation.toValue = 20.0
        animation.autoreverses = false
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        self.layer.add(animation, forKey: nil)

    }
    
    func AnimationGroup() {
        let animationGroup = CAAnimationGroup()
        animationGroup.duration = 1.0
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false

        let animation1 = CABasicAnimation(keyPath: "transform.scale")
        animation1.fromValue = 2.0
        animation1.toValue = 1.0

        let animation2 = CABasicAnimation(keyPath: "cornerRadius")
        animation2.fromValue = 0.0
        animation2.toValue = 20.0

        let animation3 = CABasicAnimation(keyPath: "transform.rotation")
        animation3.fromValue = 0.0
        animation3.toValue = .pi * 2.0
        animation3.speed = 2.0

        animationGroup.animations = [animation1, animation2, animation3]
        animationGroup.delegate = self
        self.layer.add(animationGroup, forKey: nil)
    }
}

extension Animation: CAAnimationDelegate {
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        debugPrint("animationDidStop()->")
        //アニメーションが終わったらimageViewを消す
 //       self.removeFromSuperview()
        
        debugPrint("<-animationDidStop()")
    }
}
