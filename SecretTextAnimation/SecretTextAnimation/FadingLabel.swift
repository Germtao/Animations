//
//  FadingLabel.swift
//  SecretTextAnimation
//
//  Created by QDSG on 2021/2/23.
//

import UIKit

class FadingLabel: CharacterLabel {
    override var attributedText: NSAttributedString? {
        get { super.attributedText }
        set {
            super.attributedText = newValue
            animateIn { [unowned self] _ in
                self.animateIn()
            }
        }
    }
    
    private func animateIn(_ completion: ((Bool) -> Void)? = nil) {
        for textLayer in characterTextLayers {
            let duration = TimeInterval(arc4random() % 100) / 200.0 + 0.25
            let delay = TimeInterval(arc4random() % 100) / 500.0
            
            TTLayerAnimation.animation(textLayer, duration: duration, delay: delay) {
                textLayer.opacity = 1
            }
        }
    }
    
    private func animateOut(_ completion: ((Bool) -> Void)? = nil) {
        var longestAnimation = 0.0
        var longestAnimationIndex = -1
        var index = 0
        
        for textLayer in oldCharacterTextLayers {
            let duration = TimeInterval(arc4random() % 100) / 200.0 + 0.25
            let delay = TimeInterval(arc4random() % 100) / 500.0
            
            if duration + delay > longestAnimation {
                longestAnimation = duration + delay
                longestAnimationIndex = index
            }
            
            TTLayerAnimation.animation(textLayer, duration: duration, delay: delay) {
                textLayer.opacity = 0
            } completion: { finished in
                textLayer.removeFromSuperlayer()
                if textLayer == self.oldCharacterTextLayers[longestAnimationIndex] {
                    completion?(finished)
                }
            }
            
            index += 1
        }
    }
}
