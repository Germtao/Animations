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
    
    class func animation(_ layer: CALayer, duration: TimeInterval, delay: TimeInterval, animations: (() -> Void)?, completion: ((Bool) -> Void)?) {
        
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
            
//            animGroup =
            
        }
    }
    
    class func groupAnimationsForDifferences(_ oldLayer: CALayer, newLayer: CALayer) -> CAAnimationGroup? {
        var animGroup: CAAnimationGroup?
        var anims = [CABasicAnimation]()
        
        if !CATransform3DEqualToTransform(oldLayer.transform, newLayer.transform) {
            let anim = CABasicAnimation(keyPath: "transform")
            anim.fromValue = NSValue(caTransform3D: oldLayer.transform)
            anim.toValue = NSValue(caTransform3D: newLayer.transform)
        }
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
