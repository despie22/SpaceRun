//
//  OpeningScene.swift
//  SpaceRun_despie
//
//  Created by Dylan Espie on 12/1/20.
//  Copyright © 2020 CVTC Dylan Espie. All rights reserved.
//
import SpriteKit

class OpeningScene: SKScene {
    
    typealias sceneEndCallbacktype = () -> Void
    var sceneEndCallback: sceneEndCallbacktype?
    
    private var slantedView: UIView?
    private var textView: UITextView?
    private var tapGesture: UITapGestureRecognizer?
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.black
        addChild(StarField())
        
        if let view = self.view {
            
            let slanted = UIView(frame: view.bounds)
            slantedView = slanted
            slanted.isOpaque = false
            slanted.backgroundColor = UIColor.clear
            view.addSubview(slanted)
            
            var transform = CATransform3DIdentity
            transform.m34 = -1.0 / 500.0
            transform = CATransform3DRotate(transform, CGFloat(45.0 * Double.pi / 180.0), 1.0, 0.0, 0.0)
            
            slanted.layer.transform = transform
            
            let tv = UITextView(frame: view.bounds.insetBy(dx: 30.0, dy: 0.0))
            textView = tv
            tv.isOpaque = false
            tv.backgroundColor = UIColor.clear
            tv.textColor = UIColor.yellow
            tv.font = UIFont(name: "AvenirNext-Medium", size: 20.0)
            
            // Text block for opening scene
            tv.text = "A distress call comes in from thousands of light " +
                "years away. The colony is in jeopardy and needs " +
                "your help. Enemy ships and a meteor shower " +
                "threaten the work of the galaxy's greatest " +
                "scientific minds.\n\n" +
                "Will you be able to reach " +
                "them in time to save the reasearch?\n\n" +
                "Or has the galaxy lost it's only hope?"
            tv.isUserInteractionEnabled = false
            
            tv.center = CGPoint(x: self.size.width / 2.0 + 15.0, y: self.size.height + (self.size.height / 2.0))
            
            slanted.addSubview(tv)
            
            let gradient = CAGradientLayer()
            gradient.frame = view.bounds
            gradient.colors = [UIColor.clear.cgColor, UIColor.white.cgColor]
            gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.5, y: 0.2)
            
            slanted.layer.mask = gradient
            
            // Animate the view
            UIView.animate(withDuration: 20.0,
                           delay: 0.0,
                           options: UIView.AnimationOptions.curveLinear,
                           animations: {
                            [weak self] in
                            if let weakSelf = self {
                                if let textView = weakSelf.textView {
                                    textView.center = CGPoint(x: weakSelf.size.width / 2.0, y: 0.0 - (weakSelf.size.height / 2.0))
                                }
                            }
                }, completion: {
                    [weak self] (finished: Bool) in
                    if let weakSelf = self {
                        if finished {
                            weakSelf.endScene()
                        }
                    }
            })
            
            // Tap gesture
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(OpeningScene.endScene))
            
            if tapGesture != nil {
                view.addGestureRecognizer(tapGesture!)
            }
        }
    }
    
    override func willMove(from view: SKView) {
        if self.tapGesture != nil {
            self.view?.removeGestureRecognizer(self.tapGesture!)
            self.tapGesture = nil
        }
        
        if let slantedView = slantedView {
            slantedView.removeFromSuperview()
            self.slantedView = nil
        }
    }
    
    @objc func endScene() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            if let weakSelf = self {
                if let textView = weakSelf.textView {
                    textView.alpha = 0.0
                }
            }
        }) { [weak self] (finished: Bool) in
            if let weakSelf = self {
                if let textView = weakSelf.textView {
                    textView.layer.removeAllAnimations()
                }
                if let sceneEndCallback = weakSelf.sceneEndCallback {
                    sceneEndCallback()
                } else {
                    assert(false, "Scene end callback not set.")
                }
            }
        }
        
        
    }
    
}
