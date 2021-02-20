//
//  SonarAnnotationView.swift
//  MapLocationAnimation
//
//  Created by QDSG on 2021/2/20.
//

import MapKit

class SonarAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        startAnimate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startAnimate() {
        sonar(CACurrentMediaTime())
        sonar(CACurrentMediaTime() + 0.92)
        sonar(CACurrentMediaTime() + 1.84)
    }
    
    private func sonar(_ beginTime: CFTimeInterval) {
        // 内圆
        let circlePath1 = UIBezierPath(arcCenter: center, radius: 3.0, startAngle: 0.0, endAngle: .pi * 2, clockwise: true)
        
        // 外圆
        let circlePath2 = UIBezierPath(arcCenter: center, radius: 80.0, startAngle: 0.0, endAngle: .pi * 2, clockwise: true)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = Constants.ColorPalette.green.cgColor
        shapeLayer.fillColor = Constants.ColorPalette.green.cgColor
        // 这是没有动画时可见的路径
        shapeLayer.path = circlePath1.cgPath
        layer.addSublayer(shapeLayer)
        
        // 路径 动画
        let animPath = CABasicAnimation(keyPath: "path")
        animPath.fromValue = circlePath1.cgPath
        animPath.toValue = circlePath2.cgPath
        
        // 透明度 动画
        let animAlpha = CABasicAnimation(keyPath: "opacity")
        animAlpha.fromValue = 0.8
        animAlpha.toValue = 0.0
        
        // 组动画
        let animGroup = CAAnimationGroup()
        animGroup.beginTime = beginTime
        animGroup.animations = [animPath, animAlpha]
        animGroup.duration = 2.76
        animGroup.repeatCount = .greatestFiniteMagnitude
        animGroup.isRemovedOnCompletion = false
        animGroup.fillMode = .forwards
        
        shapeLayer.add(animGroup, forKey: "sonar")
    }
}
