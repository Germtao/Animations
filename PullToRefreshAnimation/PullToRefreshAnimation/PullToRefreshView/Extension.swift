//
//  Extension.swift
//  PullToRefreshAnimation
//
//  Created by QDSG on 2021/2/22.
//

import UIKit

extension CGPath {
    /// 调用 Objective-C 的方法时候，可以传入修饰过@convention(block)的函数类型，匹配 Objective-C 方法参数中的 block 参数
    func forEach(body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        func callback(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let body = unsafeBitCast(info, to: Body.self)
            body(element.pointee)
        }
        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        apply(info: unsafeBody, function: callback)
    }
}

extension UIBezierPath {
    /// 查找路径中的第一个点, 使用上面创建的CGPath扩展
    /// 这用于在开始时添加飞碟图像
    /// 动画路径
    func firstPoint() -> CGPoint? {
        var firstPoint: CGPoint? = nil
        
        cgPath.forEach { element in
            // 只想要第一个，但我们必须看一切
            guard firstPoint == nil else { return }
            assert(element.type == .moveToPoint, "Expected the first point to be a move")
            firstPoint = element.points.pointee
        }
        return firstPoint
    }
}

func delay(seconds: Double, completion: @escaping () -> Void) {
    let popTime = DispatchTime.now() + Double(Int64(Double(NSEC_PER_SEC) * seconds)) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) {
        completion()
    }
}
