//
//  ViewController.swift
//  UIViewPropertyAnimator-demo
//
//  Created by QDSG on 2021/2/6.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var showView: UIView! {
        didSet {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handle(_:)))
            showView.addGestureRecognizer(pan)
        }
    }
    
    var animator = UIViewPropertyAnimator()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func handle(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 3, curve: .easeOut, animations: {
                self.showView.transform = CGAffineTransform(translationX: 200, y: 0)
                self.showView.alpha = 0.0
            })
            animator.startAnimation()
            animator.pauseAnimation()
        case .changed:
            // 将视图与用户的触摸一起移动
            animator.fractionComplete = gesture.translation(in: showView).x / 200
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
}

