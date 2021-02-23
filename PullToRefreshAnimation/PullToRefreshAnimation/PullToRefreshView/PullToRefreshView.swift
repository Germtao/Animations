//
//  PullToRefreshView.swift
//  PullToRefreshAnimation
//
//  Created by QDSG on 2021/2/22.
//

import UIKit

struct Constants {
    struct Images {
        static let pullRefreshViewBackground = "pull-refresh-view-background"
        static let flyingSaucer = "flying-saucer"
    }
    
    struct ColorPalette {
        static let pruple = UIColor(red: 0.31, green: 0.20, blue: 0.49, alpha: 1.0)
        static let backgroundColor = UIColor(red: 43/255, green: 35/255, blue: 77/255, alpha: 1)
    }
}

protocol PullToRefreshViewDelegate {
    func pullToRefreshViewDidRefresh(_ pullToRefreshView: PullToRefreshView)
}

class PullToRefreshView: UIView, UIScrollViewDelegate {
    
    var delegate: PullToRefreshViewDelegate?
    
    private var scrollView: UIScrollView?
    private var progress: CGFloat = 0.0
    private var isRefreshing = false
    
    private let flyingSaucerLayer = CALayer()
    
    private var paths = [UIBezierPath]()
    
    init(frame: CGRect, scrollView: UIScrollView) {
        super.init(frame: frame)
        
        self.scrollView = scrollView
        
        // 添加背景图
        let backgroundImageView = UIImageView(image: UIImage(named: Constants.Images.pullRefreshViewBackground))
        backgroundImageView.frame = bounds
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        addSubview(backgroundImageView)
        
        // 创建供飞碟动画的自定义路径
        paths = customPaths(frame: CGRect(x: 20, y: bounds.size.height / 5, width: bounds.size.width / 1.8, height: bounds.size.height / 1.5))
        
        // 添加飞碟图像
        let flyingSaucerImage = UIImage(named: Constants.Images.flyingSaucer)!
        flyingSaucerLayer.contents = flyingSaucerImage.cgImage
        flyingSaucerLayer.bounds = CGRect(x: 0.0, y: 0.0, width: flyingSaucerImage.size.width, height: flyingSaucerImage.size.height)
        
        let enterPath = paths[0]
        // 它的初始位置将在路径的第一点
        flyingSaucerLayer.position = enterPath.firstPoint()!
        
        print("firstPoint: \(enterPath.firstPoint()!)")
        
        layer.addSublayer(flyingSaucerLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = max(-(scrollView.contentOffset.y + scrollView.contentInset.top), 0.0)
        progress = min(max(offsetY / frame.height, 0.0), 1.0)
        
        if !isRefreshing && progress >= 0.5 {
            print("progress: \(progress) - isRefreshing: \(isRefreshing)")
            redrawFromProgress(progress)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if !isRefreshing && progress >= 1.0 {
            delegate?.pullToRefreshViewDidRefresh(self)
            
            beginRefreshing()
        }
    }
}

extension PullToRefreshView {
    private func beginRefreshing() {
        isRefreshing = true
        
        UIView.animate(withDuration: 0.3) {
            var newInsets = self.scrollView!.contentInset
            newInsets.top += self.frame.height
            self.scrollView?.contentInset = newInsets
        }
        
        /* 第 2 部分：悬停动画 */
        
        let hoverAnim = CABasicAnimation(keyPath: "position")
        hoverAnim.isAdditive = true
        hoverAnim.fromValue = NSValue(cgPoint: .zero)
        hoverAnim.toValue = NSValue(cgPoint: CGPoint(x: 0.0, y: 50.0))
        hoverAnim.autoreverses = true
        hoverAnim.duration = 0.7
        hoverAnim.repeatCount = 2
        hoverAnim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        hoverAnim.isRemovedOnCompletion = false
        hoverAnim.fillMode = .forwards
        
        flyingSaucerLayer.add(hoverAnim, forKey: nil)
        
        let enterPath = paths[0]
        flyingSaucerLayer.position = enterPath.currentPoint
    }
    
    func endRefreshing() {
        isRefreshing = false
        
        UIView.animate(withDuration: 0.3, delay: 0.2, options: .curveEaseOut) {
            var newInsets = self.scrollView!.contentInset
            newInsets.top -= self.frame.height
            self.scrollView?.contentInset = newInsets
        }
        
        /* 第 3 部分：退出动画 */
        
        let exitPath = paths[1]
        
        // 沿退出路径对图像进行动画处理
        let exitPathAnim = CAKeyframeAnimation(keyPath: "position")
        exitPathAnim.path = exitPath.cgPath
        exitPathAnim.calculationMode = .paced
        exitPathAnim.timingFunctions = [CAMediaTimingFunction(name: .easeOut)]
        exitPathAnim.beginTime = CFTimeInterval()
        exitPathAnim.duration = 0.3
        exitPathAnim.isRemovedOnCompletion = true
        exitPathAnim.fillMode = .forwards
        
        // 沿退出路径设置动画大小
        let sizeAlongExitPathAnim = CABasicAnimation(keyPath: "transform.scale")
        sizeAlongExitPathAnim.fromValue = 1
        sizeAlongExitPathAnim.toValue = 0
        sizeAlongExitPathAnim.duration = 0.3
        sizeAlongExitPathAnim.beginTime = CFTimeInterval()
        sizeAlongExitPathAnim.isRemovedOnCompletion = true
        sizeAlongExitPathAnim.fillMode = .forwards
        
        flyingSaucerLayer.add(exitPathAnim, forKey: nil)
        flyingSaucerLayer.add(sizeAlongExitPathAnim, forKey: nil)
        
        print("结束刷新 currentPosition = \(exitPath.currentPoint)")
    }
    
    private func redrawFromProgress(_ progress: CGFloat) {
        
        /* 第 1 部分：输入动画 */
        
        let enterPath = paths[0]
        
        // 沿输入路径对图像进行动画处理
        let pathAnim = CAKeyframeAnimation(keyPath: "position")
        pathAnim.path = enterPath.cgPath
        pathAnim.calculationMode = .paced
        pathAnim.timingFunctions = [CAMediaTimingFunction(name: .easeOut)]
        pathAnim.beginTime = CFTimeInterval()
        pathAnim.duration = 1.0
        pathAnim.timeOffset = CFTimeInterval() + Double(progress)
        pathAnim.isRemovedOnCompletion = false
        pathAnim.fillMode = .forwards
        
        // 沿输入路径设置动画大小
        let sizeAlongEnterPathAnimation = CABasicAnimation(keyPath: "transform.scale")
        sizeAlongEnterPathAnimation.fromValue = 0
        sizeAlongEnterPathAnimation.toValue = progress
        sizeAlongEnterPathAnimation.beginTime = CFTimeInterval()
        sizeAlongEnterPathAnimation.duration = 1.0
        sizeAlongEnterPathAnimation.isRemovedOnCompletion = false
        sizeAlongEnterPathAnimation.fillMode = .forwards
        
        flyingSaucerLayer.position = enterPath.currentPoint
        flyingSaucerLayer.add(pathAnim, forKey: nil)
        flyingSaucerLayer.add(sizeAlongEnterPathAnimation, forKey: nil)
        
        print("currentPosition = \(enterPath.currentPoint)")
    }
    
    private func customPaths(frame: CGRect = CGRect(x: 4, y: 3, width: 166, height: 74)) -> [UIBezierPath] {
        // 返回2条不同的路径：Enter和Exit
        
        let enterPath = UIBezierPath()
        enterPath.move(to: CGPoint(x: frame.minX + 0.08146 * frame.width, y: frame.minY + 0.09459 * frame.height))
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.03076 * frame.width, y: frame.minY + 0.26040 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.08146 * frame.width, y: frame.minY + 0.09459 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.03814 * frame.width, y: frame.minY + 0.17848 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.03169 * frame.width, y: frame.minY + 0.48077 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.02980 * frame.width, y: frame.minY + 0.27114 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.01776 * frame.width, y: frame.minY + 0.31165 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.21694 * frame.width, y: frame.minY + 0.85855 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.04828 * frame.width, y: frame.minY + 0.68225 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.21694 * frame.width, y: frame.minY + 0.85855 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.36994 * frame.width, y: frame.minY + 0.92990 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.21694 * frame.width, y: frame.minY + 0.85855 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.33123 * frame.width, y: frame.minY + 0.93830 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.41416 * frame.width, y: frame.minY + 0.92165 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.40865 * frame.width, y: frame.minY + 0.92151 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.39224 * frame.width, y: frame.minY + 0.92548 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.48146 * frame.width, y: frame.minY + 0.90262 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.43661 * frame.width, y: frame.minY + 0.91773 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.46286 * frame.width, y: frame.minY + 0.91204 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.73584 * frame.width, y: frame.minY + 0.61929 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.55989 * frame.width, y: frame.minY + 0.86290 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.68159 * frame.width, y: frame.minY + 0.72568 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.89621 * frame.width, y: frame.minY + 0.34225 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.75763 * frame.width, y: frame.minY + 0.57655 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.83515 * frame.width, y: frame.minY + 0.45666 * frame.height)
        )
        enterPath.addCurve(
            to: CGPoint(x: frame.minX + 0.98193 * frame.width, y: frame.minY + 0.15336 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.93621 * frame.width, y: frame.minY + 0.26730 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.96431 * frame.width, y: frame.minY + 0.19090 * frame.height)
        )
        enterPath.miterLimit = 4
        enterPath.usesEvenOddFillRule = true
        
        let exitPath = UIBezierPath()
        exitPath.move(to: CGPoint(x: frame.minX + 0.98193 * frame.width, y: frame.minY + 0.15336 * frame.height))
        exitPath.addLine(to: CGPoint(x: frame.minX + 0.51372 * frame.width, y: frame.minY + 0.28558 * frame.height))
        exitPath.addCurve(
            to: CGPoint(x: frame.minX + 0.47040 * frame.width, y: frame.minY + 0.25830 * frame.height),
            controlPoint1: CGPoint(x: frame.minX + 0.51372 * frame.width, y: frame.minY + 0.28558 * frame.height),
            controlPoint2: CGPoint(x: frame.minX + 0.47685 * frame.width, y: frame.minY + 0.29556 * frame.height)
        )
        exitPath.miterLimit = 4
        exitPath.usesEvenOddFillRule = true
        
        return [enterPath, exitPath]
    }
}
