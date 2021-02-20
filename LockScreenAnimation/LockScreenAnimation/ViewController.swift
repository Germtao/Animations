//
//  ViewController.swift
//  LockScreenAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var topLock: UIImageView!
    @IBOutlet private weak var bottomLock: UIImageView!
    @IBOutlet private weak var lockBorder: UIImageView!
    @IBOutlet private weak var lockKeyhole: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        openLock()
    }

    override var prefersStatusBarHidden: Bool { return true }
    
    private func openLock() {
        UIView.animate(withDuration: 0.4, delay: 5.0, options: []) {
            // 旋转锁孔
            self.lockKeyhole.transform = CGAffineTransform(rotationAngle: .pi / 2)
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0.2, options: []) {
                // 开锁
                let yDetal = self.lockBorder.frame.maxY
                
                self.topLock.center.y -= yDetal
                self.lockKeyhole.center.y -= yDetal
                self.lockBorder.center.y -= yDetal
                self.bottomLock.center.y += yDetal
                
            } completion: { _ in
                self.topLock.removeFromSuperview()
                self.lockKeyhole.removeFromSuperview()
                self.lockBorder.removeFromSuperview()
                self.bottomLock.removeFromSuperview()
            }

        }

    }
}

