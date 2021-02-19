//
//  ViewController.swift
//  UIViewPropertyAnimator-demo
//
//  Created by QDSG on 2021/2/6.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Constants
    
    private let popupOffset: CGFloat = 440
    
    // MARK: - Animations
    
    private var currentState: PropertyAnimatorState = .closed
    
    var animator = UIViewPropertyAnimator()
    
    /// 所有当前正在运行的动画器
    private var runningAnimator = UIViewPropertyAnimator()
    
    /// 每个动画器的进度。这个数组与`runningAnimators`数组平行
    private var animationProgress: CGFloat = 0
    
    // MARK: - Views
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var panGesture = InstantPanGestureRecognizer(target: self, action: #selector(popupViewPanned(_:)))
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        popupView.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Layout
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func layout() {
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: popupOffset)
        bottomConstraint.isActive = true
    }
}

extension ViewController {
    
    @objc private func popupViewPanned(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // 开始动画
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1.5)
            
            // 暂停所有动画，因为下一个事件可能是平移
//            runningAnimators.forEach { $0.pauseAnimation() }
            runningAnimator.pauseAnimation()
            
            // 跟踪每个动画器的进度
//            animationProgress = runningAnimators.map { $0.fractionComplete }
            animationProgress = runningAnimator.fractionComplete
            
        case .changed:
            
            // 变量设置
            let transition = gesture.translation(in: popupView)
            var fraction = -transition.y / popupOffset
            
            // 调整当前状态和反转状态的分数
            if currentState == .open { fraction *= -1 }
//            if runningAnimators[0].isReversed { fraction *= -1 }
            
//            for (index, animator) in runningAnimators.enumerated() {
//                animator.fractionComplete = fraction + animationProgress[index]
//            }
            runningAnimator.fractionComplete = fraction + animationProgress
            
        case .ended:
            
//            let yVelocity = gesture.velocity(in: popupView).y
//            let shouldClose = yVelocity > 0
            
            // 如果没有动作，请继续所有动画并尽早退出
//            if yVelocity == 0 {
//                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
//                break
//            }
            
            // 根据动画的当前状态和平移动画来反转动画
//            switch currentState {
//            case .open:
//                if !shouldClose && !runningAnimators[0].isReversed {
//                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
//                }
//                if shouldClose && runningAnimators[0].isReversed {
//                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
//                }
//            case .closed:
//                if shouldClose && !runningAnimators[0].isReversed {
//                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
//                }
//                if !shouldClose && runningAnimators[0].isReversed {
//                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
//                }
//            }
            
            // 继续所有动画
//            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            runningAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
            
        default:
            break
        }
    }
}

extension ViewController {
    /// 对过渡进行动画处理（如果动画尚未运行）
    private func animateTransitionIfNeeded(to state: PropertyAnimatorState, duration: TimeInterval) {
        // 确保animators数组为空（这意味着需要创建新的动画）
//        guard runningAnimators.isEmpty else { return }
        
        // 过渡的动画器
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
            }
            self.view.layoutIfNeeded()
        }
        transitionAnimator.addCompletion { position in
            switch position {
            case .start:
                self.currentState = state.opposite
            case .end:
                self.currentState = state
            default:
                break
            }
            
            // 手动重置约束位置
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
            }
            
            // 删除所有正在运行的动画器
//            self.runningAnimators.removeAll()
        }
        
        // 启动所有动画器
        transitionAnimator.startAnimation()
        
        // 跟踪所有正在运行的动画器
//        runningAnimators.append(transitionAnimator)
        runningAnimator = transitionAnimator
    }
}

