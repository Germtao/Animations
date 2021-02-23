//
//  TTLayerAnimation.swift
//  SecretTextAnimation
//
//  Created by TT on 2021/2/22.
//

import Foundation
import QuartzCore

class TTLayerAnimation: NSObject {
    
    var completion: ((Bool) -> Void)?
    
    var layer: CALayer!
    
    class func animation(_ layer: CALayer, duration: TimeInterval, delay: TimeInterval, animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        
        let anim = TTLayerAnimation()
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
            
            var animGroup: CAAnimationGroup?
            let oldLayer = self.animatableLayerCopy(layer)
            anim.completion = completion
            
            if let layerAnims = animations {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                layerAnims()
                CATransaction.commit()
            }
            
            animGroup = self.groupAnimationsForDifferences(oldLayer, newLayer: layer)
            
            guard let differenceAnim = animGroup else {
                completion?(true)
                return
            }
            
            differenceAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            differenceAnim.duration = duration
            differenceAnim.beginTime = CACurrentMediaTime()
            
            layer.add(differenceAnim, forKey: nil)
        }
    }
    
    class func groupAnimationsForDifferences(_ oldLayer: CALayer, newLayer: CALayer) -> CAAnimationGroup? {
        var animGroup: CAAnimationGroup?
        var anims = [CABasicAnimation]()
        
        if !CATransform3DEqualToTransform(oldLayer.transform, newLayer.transform) {
            let anim = CABasicAnimation(keyPath: "transform")
            anim.fromValue = NSValue(caTransform3D: oldLayer.transform)
            anim.toValue = NSValue(caTransform3D: newLayer.transform)
            anims.append(anim)
        }
        
        if !oldLayer.bounds.equalTo(newLayer.bounds) {
            let anim = CABasicAnimation(keyPath: "bounds")
            anim.fromValue = NSValue(cgRect: oldLayer.bounds)
            anim.toValue = NSValue(cgRect: newLayer.bounds)
            anims.append(anim)
        }
        
        if !oldLayer.frame.equalTo(newLayer.frame) {
            let anim = CABasicAnimation(keyPath: "frame")
            anim.fromValue = NSValue(cgRect: oldLayer.frame)
            anim.toValue = NSValue(cgRect: newLayer.frame)
            anims.append(anim)
        }
        
        if !oldLayer.position.equalTo(newLayer.position) {
            let anim = CABasicAnimation(keyPath: "position")
            anim.fromValue = NSValue(cgPoint: oldLayer.position)
            anim.toValue = NSValue(cgPoint: newLayer.position)
            anims.append(anim)
        }
        
        if oldLayer.opacity != newLayer.opacity {
            let anim = CABasicAnimation(keyPath: "opacity")
            anim.fromValue = oldLayer.opacity
            anim.toValue = newLayer.opacity
            anims.append(anim)
        }
        
        if anims.count > 0 {
            animGroup = CAAnimationGroup()
            animGroup?.animations = anims
        }
        
        return animGroup
    }
    
    class func animatableLayerCopy(_ layer: CALayer) -> CALayer {
        let layerCopy = CALayer()
        
        layerCopy.opacity = layer.opacity
        layerCopy.transform = layer.transform
        layerCopy.bounds = layer.bounds
        layerCopy.position = layer.position
        
        return layerCopy
    }
}
