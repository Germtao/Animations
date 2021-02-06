//
//  ViewController.swift
//  UIViewPropertyAnimator-demo
//
//  Created by QDSG on 2021/2/6.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var showView: UIView! {
        didSet {
            showView.isHidden = true
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handle(_:)))
            showView.addGestureRecognizer(pan)
        }
    }
    
    var animator = UIViewPropertyAnimator()
    
    private lazy var popupView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(popupViewTapped(_:)))
    
    private var bottomConstraint = NSLayoutConstraint()
    
    private var currentState: PropertyAnimatorState = .closed

    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        popupView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handle(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            animator = UIViewPropertyAnimator(duration: 3, curve: .easeOut, animations: {
                self.showView.transform = CGAffineTransform(translationX: 200, y: 0)
                self.showView.alpha = 0.0
            })
            animator.startAnimation()
            animator.pauseAnimation()
        case .changed:
            // 将视图与用户的触摸一起移动
            animator.fractionComplete = gesture.translation(in: showView).x / 200
        case .ended:
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        default:
            break
        }
    }
}

extension ViewController {
    private func layout() {
        popupView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(popupView)
        
        popupView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        popupView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        popupView.heightAnchor.constraint(equalToConstant: 500).isActive = true
        bottomConstraint = popupView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 440)
        bottomConstraint.isActive = true
    }
    
    @objc private func popupViewTapped(_ gesture: UITapGestureRecognizer) {
        let state = currentState.opposite
        let transitionAnimator = UIViewPropertyAnimator(duration: 1, dampingRatio: 1) {
            switch state {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = 440
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
            
            switch self.currentState {
            case .open:
                self.bottomConstraint.constant = 0
            case .closed:
                self.bottomConstraint.constant = 440
            }
        }
        transitionAnimator.startAnimation()
    }
}

