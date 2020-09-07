//
//  AnimationViewController.swift
//  GrouPhone
//
//  Created by 土師一哉 on 2020/08/27.
//  Copyright © 2020 土師一哉. All rights reserved.
//

import UIKit

class AnimationViewController: UINavigationController {
//class AnimationViewController: UIViewController {

    var labelx:UILabel?
    var animation:Animation?
    var pngAnimation:PngAnimation?
    var animationView:Animation?
    var animationBtn:UIButton?
    
//    @IBOutlet weak var anime: UIImageView!
    
    @IBOutlet weak var start: UIButton!
//    @IBOutlet weak var label: UILabel!
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
//        self.view.addSubview(pngAnimation!)
        
        animationBtn = UIButton(frame: animationFrame)
        animationBtn?.setTitle("animation button", for: .normal)
        animationBtn?.setTitleColor(.black, for: .normal)
        animationBtn?.backgroundColor = .blue
        // ボタンを押した時に実行するメソッドを指定
        animationBtn?.addTarget(self, action: #selector(buttonEvent(_:)), for: UIControl.Event.touchUpInside)
        
        self.view.addSubview(animationBtn!)


        
//        animationView = Animation(frame: animationFrame)
//        self.view.addSubview(animationView!)
        
    }
    
    // ボタンが押された時に呼ばれるメソッド
    @objc func buttonEvent(_ sender: UIButton) {
        debugPrint("buttonEvent()->")
        let second = AnimationSecondViewController()
//        let navi = UINavigationController(rootViewController: self)
        self.pushViewController(second, animated: true)
        debugPrint("<-buttonEvent()")
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        //もともとのアニメーションを削除
        self.view.layer.removeAllAnimations()
        if(animated){
            //新しいアニメーションをつける
            let transition:CATransition = CATransition()
            transition.duration = 0.25
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromRight
            self.view.layer.add(transition,forKey:kCATransition)
        }
        return super.pushViewController(viewController, animated: false)
    }
    
    
    @IBAction func tapStart(_ sender: Any) {
     
 UIView.animateKeyframes(withDuration: 2.0, delay: 0.0, options: [.autoreverse], animations: {

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.25, animations: {
                self.animationBtn?.center.y += 100.0
            })

            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1, animations: {
                self.animationBtn?.transform = CGAffineTransform(rotationAngle: .pi / 2)
            })

            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25, animations: {
                self.animationBtn?.center.x += 100.0
            })

            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.1, animations: {
                self.animationBtn?.transform = CGAffineTransform(rotationAngle: .pi)
            })

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25, animations: {
                self.animationBtn?.center.y -= 100.0
            })

            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.1, animations: {
                self.animationBtn?.transform = CGAffineTransform(rotationAngle: .pi + .pi / 2)
            })

            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25, animations: {
                self.animationBtn?.center.x -= 100.0
            })

            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.1, animations: {
                self.animationBtn?.transform = CGAffineTransform(rotationAngle: .pi * 2)
            })

        }, completion: nil)
 
//        self.animationBtn?.center.y -= 100.0
        
//        animationView = Animation(frame: animationFrame)
//        self.view.addSubview(animationView!)
//        animationView?.animateLayer()
        
//        animationView?.AnimationGroup()
    }
    
    
    func shakeView(vw: UIView) {
        let animation = CAKeyframeAnimation()
        animation.keyPath = "position.x"
        animation.values = [0, 10, -10, 10, -5, 5, -5, 0 ]
        animation.keyTimes = [0, 0.125, 0.25, 0.375, 0.5, 0.625, 0.75, 0.875, 1]
        animation.duration = 0.4
        animation.isAdditive = true

        vw.layer.add(animation, forKey: "position.x")
    
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
