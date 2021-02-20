//
//  ViewController.swift
//  LoadingDotsAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet private weak var loadingDots: LoadingDots!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLoading()
    }

    override var prefersStatusBarHidden: Bool { return true }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        startLoading()
    }
    
    private func startLoading() {
        self.loadingDots.startAnimate()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5) {
            self.loadingDots.stopAnimate()
        }
    }
}

