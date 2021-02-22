//
//  LoadingLabel.swift
//  GradientAnimation
//
//  Created by QDSG on 2021/2/22.
//

import UIKit
import Foundation

struct Constants {
    struct Fonts {
        static let loadingLabel = "HelveticaNeue-UltraLight"
    }
}

@IBDesignable class LoadingLabel: UIView {
    
    @IBInspectable var text: String! {
        didSet {
            setNeedsDisplay()
            
            // 创建临时图形上下文，以将文本呈现为图像
            UIGraphicsBeginImageContextWithOptions(frame.size, false, 0)
            (text as NSString).draw(in: bounds, withAttributes: textAttributes)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.clear.cgColor
            maskLayer.frame = bounds.offsetBy(dx: bounds.width, dy: 0)
            maskLayer.contents = image?.cgImage
            
            gradientLayer.mask = maskLayer
        }
    }
    
    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        
        layer.startPoint = CGPoint(x: 0.0, y: 0.5)
        layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        let colors = [UIColor.gray.cgColor, UIColor.white.cgColor, UIColor.gray.cgColor]
        layer.colors = colors
        
        let locations = [0.25, 0.5, 0.75]
        layer.locations = locations as [NSNumber]?
        
        return layer
    }()
    
    private let textAttributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let attributes = [
            NSAttributedString.Key.font: UIFont(name: Constants.Fonts.loadingLabel, size: 70.0)!,
            NSAttributedString.Key.paragraphStyle: style
        ]
        
        return attributes
    }()
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        gradientLayer.frame = CGRect(x: -bounds.width, y: bounds.minY, width: bounds.width * 3, height: bounds.height)
        layer.addSublayer(gradientLayer)
        
        let gradientAnim = CABasicAnimation(keyPath: "locations")
        gradientAnim.fromValue = [0.0, 0.0, 0.25]
        gradientAnim.toValue = [0.75, 1.0, 1.0]
        gradientAnim.duration = 1.7
        gradientAnim.repeatCount = .infinity
        gradientAnim.isRemovedOnCompletion = false
        gradientAnim.fillMode = .forwards
        
        gradientLayer.add(gradientAnim, forKey: nil)
    }
}
