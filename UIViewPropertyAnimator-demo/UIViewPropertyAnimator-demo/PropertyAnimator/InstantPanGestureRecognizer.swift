//
//  InstantPanGestureRecognizer.swift
//  UIViewPropertyAnimator-demo
//
//  Created by QDSG on 2021/2/19.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if self.state == .began { return }
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
