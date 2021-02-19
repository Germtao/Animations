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
    
    /// 所有当前正在运行的动画器
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    /// 每个动画器的进度。这个数组与`runningAnimators`数组平行
    private var animationProgress = [CGFloat]()
    
    private lazy var panGesture = InstantPanGestureRecognizer(target: self, action: #selector(popupViewPanned(_:)))
    
    // MARK: - Views
    
    private lazy var contentImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "content")
        return imageView
    }()
    
    private lazy var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0
        return view
    }()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowRadius = 10
        return view
    }()
    
    private lazy var closedTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "评论"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = #colorLiteral(red: 0, green: 0.59, blue: 1, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var openTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "评论"
        label.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        label.textColor = .black
        label.textAlignment = .center
        label.alpha = 0
        label.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
        return label
    }()
    
    private lazy var reviewsImgView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "reviews")
        return imageView
    }()
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        popupView.addGestureRecognizer(panGesture)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Layout
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private func layout() {
        contentImgView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentImgView)
        contentImgView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentImgView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentImgView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        contentImgView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
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
        
        closedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(closedTitleLabel)
        closedTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        closedTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        closedTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 20).isActive = true
        
        openTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(openTitleLabel)
        openTitleLabel.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        openTitleLabel.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        openTitleLabel.topAnchor.constraint(equalTo: popupView.topAnchor, constant: 30).isActive = true
        
        reviewsImgView.translatesAutoresizingMaskIntoConstraints = false
        popupView.addSubview(reviewsImgView)
        reviewsImgView.leadingAnchor.constraint(equalTo: popupView.leadingAnchor).isActive = true
        reviewsImgView.trailingAnchor.constraint(equalTo: popupView.trailingAnchor).isActive = true
        reviewsImgView.bottomAnchor.constraint(equalTo: popupView.bottomAnchor).isActive = true
        reviewsImgView.heightAnchor.constraint(equalToConstant: 428).isActive = true
    }
}

extension ViewController {
    
    @objc private func popupViewPanned(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            // 开始动画
            animateTransitionIfNeeded(to: currentState.opposite, duration: 1.5)
            
            // 暂停所有动画，因为下一个事件可能是平移
            runningAnimators.forEach { $0.pauseAnimation() }
            
            // 跟踪每个动画器的进度
            animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            
            // 变量设置
            let transition = gesture.translation(in: popupView)
            var fraction = -transition.y / popupOffset
            
            // 调整当前状态和反转状态的 fraction
            if currentState == .open { fraction *= -1 }
            if runningAnimators[0].isReversed { fraction *= -1 }
            
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
        case .ended:
            
            let yVelocity = gesture.velocity(in: popupView).y
            let shouldClose = yVelocity > 0
            
            // 如果没有动作，请继续所有动画并尽早退出
            if yVelocity == 0 {
                runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
                break
            }
            
            // 根据动画的当前状态和平移动画来反转动画
            switch currentState {
            case .open:
                if !shouldClose && !runningAnimators[0].isReversed {
                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
                }
                if shouldClose && runningAnimators[0].isReversed {
                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
                }
            case .closed:
                if shouldClose && !runningAnimators[0].isReversed {
                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
                }
                if !shouldClose && runningAnimators[0].isReversed {
                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
                }
            }
            
            // 继续所有动画
            runningAnimators.forEach { $0.continueAnimation(withTimingParameters: nil, durationFactor: 0) }
            
        default:
            break
        }
    }
}

extension ViewController {
    /// 对过渡进行动画处理（如果动画尚未运行）
    private func animateTransitionIfNeeded(to state: PropertyAnimatorState, duration: TimeInterval) {
        // 确保animators数组为空（这意味着需要创建新的动画）
        guard runningAnimators.isEmpty else { return }
        
        // 过渡的动画器
        let transitionAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
                self.popupView.layer.cornerRadius = 20
                self.overlayView.alpha = 0.5
                self.closedTitleLabel.transform = CGAffineTransform(scaleX: 1.6, y: 1.6).concatenating(CGAffineTransform(translationX: 0, y: 15))
                self.openTitleLabel.transform = .identity
            case .closed:
                self.bottomConstraint.constant = self.popupOffset
                self.popupView.layer.cornerRadius = 0
                self.overlayView.alpha = 0
                self.closedTitleLabel.transform = .identity
                self.openTitleLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65).concatenating(CGAffineTransform(translationX: 0, y: -15))
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
            self.runningAnimators.removeAll()
        }
        
        // 过渡到视图的标题的动画器
        let inTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeIn) {
            switch state {
            case .open:
                self.openTitleLabel.alpha = 1
            case .closed:
                self.closedTitleLabel.alpha = 1
            }
        }
        inTitleAnimator.scrubsLinearly = false
        
        // 过渡到视线之外的标题的动画器
        let outTitleAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut) {
            switch state {
            case .open:
                self.closedTitleLabel.alpha = 0
            case .closed:
                self.openTitleLabel.alpha = 0
            }
        }
        outTitleAnimator.scrubsLinearly = false
        
        // 启动所有动画器
        transitionAnimator.startAnimation()
        inTitleAnimator.startAnimation()
        outTitleAnimator.startAnimation()
        
        // 跟踪所有正在运行的动画器
        runningAnimators.append(transitionAnimator)
        runningAnimators.append(inTitleAnimator)
        runningAnimators.append(outTitleAnimator)
    }
}

