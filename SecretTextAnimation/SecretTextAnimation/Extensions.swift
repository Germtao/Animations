//
//  Extensions.swift
//  SecretTextAnimation
//
//  Created by TT on 2021/2/22.
//

import UIKit

extension CATextLayer {
    convenience init(frame: CGRect, attributeString string: NSAttributedString) {
        self.init()
        self.contentsScale = UIScreen.main.scale
        self.frame = frame
        self.string = string
    }
}
