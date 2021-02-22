//
//  ProgressView.swift
//  ProgressAnimation
//
//  Created by QDSG on 2021/2/22.
//

import UIKit

@IBDesignable
class ProgressView: UIView {
    let progressLayer = CAShapeLayer()
    let gradientLayer = CAGradientLayer()
    
    var range: CGFloat = 128
    var curValue: CGFloat = 0 {
        didSet {
            animateStroke()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayers()
    }
    
    private func setupLayers() {
        
        // 设置 progress layer
        progressLayer.position = .zero
        progressLayer.lineWidth = 3.0
        progressLayer.strokeEnd = 0.0
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.black.cgColor
        
        let radius = bounds.height / 2 - progressLayer.lineWidth
        let startAngle = -CGFloat.pi / 2
        let endAngle = CGFloat.pi * 3 / 2
        let width = bounds.width
        let height = bounds.height
        let modelCenter = CGPoint(x: width / 2, y: height / 2)
        let path = UIBezierPath(arcCenter: modelCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        
        progressLayer.path = path.cgPath
        layer.addSublayer(progressLayer)
        
        // 设置 gradient layer
        gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: bounds.height)
        gradientLayer.colors = [
            Constants.ColorPalette.teal.cgColor,
            Constants.ColorPalette.orange.cgColor,
            Constants.ColorPalette.pink.cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.mask = progressLayer
        layer.addSublayer(gradientLayer)
    }
    
    private func animateStroke() {
        let fromValue = progressLayer.strokeEnd
        let toValue = curValue / range
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = fromValue
        animation.toValue = toValue
        
        progressLayer.add(animation, forKey: "stroke")
        progressLayer.strokeEnd = toValue
    }
}
