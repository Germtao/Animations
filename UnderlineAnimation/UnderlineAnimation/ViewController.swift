//
//  ViewController.swift
//  UnderlineAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUnderline()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 当我在viewWillAppear中调用（optionsBar.frame.width / 2）时，框架不正确。
        // 因此，在这里我将宽度约束更新为此。
        // 当视图旋转时，这也会更新约束。
        for constraint in underlineView.constraints {
            if constraint.identifier == Constants.ConstraintIdentifiers.widthConstraintIdentifier {
                constraint.constant = optionsBar.frame.width / 3.5
                view.layoutIfNeeded()
            }
        }
    }

    @IBOutlet private weak var optionsBar: UIStackView!
    
    private lazy var underlineView = Underline()
    
    @IBAction private func leftButtonAction() {
        animateConstraintsForUnderline(underlineView, toSide: .left)
    }
    
    @IBAction private func centerButtonAction() {
        animateConstraintsForUnderline(underlineView, toSide: .center)
    }
    
    @IBAction private func rightButtonAction() {
        animateConstraintsForUnderline(underlineView, toSide: .right)
    }
}

extension ViewController {
    private func configureNavBar() {
        navigationController?.navigationBar.barTintColor = Constants.ColorPalette.green
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
    
    private func setupUnderline() {
        view.addSubview(underlineView)
        
        let topConstraint = underlineView.topAnchor.constraint(equalTo: optionsBar.bottomAnchor)
        let heightConstraint = underlineView.heightAnchor.constraint(equalToConstant: 2)
        
        let leftButton = optionsBar.arrangedSubviews[0]
        let centerLeftConstraint = underlineView.centerXAnchor.constraint(equalTo: leftButton.centerXAnchor)
        centerLeftConstraint.identifier = Constants.ConstraintIdentifiers.centerLeftConstraintIdentifier
        
        // 此处的框架设置不正确，因此我在viewDidLayoutSubviews中再次更新了该值。
        let widthConstraint = underlineView.widthAnchor.constraint(equalToConstant: optionsBar.frame.width / 2.5)
        widthConstraint.identifier = Constants.ConstraintIdentifiers.widthConstraintIdentifier
        
        NSLayoutConstraint.activate([topConstraint, heightConstraint, widthConstraint, centerLeftConstraint])
    }
    
    private func animateConstraintsForUnderline(_ underline: UIView, toSide: Side) {
        switch toSide {
        case .left:
            for constraint in underline.superview!.constraints {
                if constraint.identifier == Constants.ConstraintIdentifiers.centerRightConstraintIdentifier || constraint.identifier == Constants.ConstraintIdentifiers.centerCenterConstraintIdentifier {
                    constraint.isActive = false
                    
                    let leftButton = optionsBar.arrangedSubviews[0]
                    let centerLeftConstraint = underline.centerXAnchor.constraint(equalTo: leftButton.centerXAnchor)
                    centerLeftConstraint.identifier = Constants.ConstraintIdentifiers.centerLeftConstraintIdentifier
                    
                    NSLayoutConstraint.activate([centerLeftConstraint])
                }
            }
        case .center:
            for constraint in underline.superview!.constraints {
                if constraint.identifier == Constants.ConstraintIdentifiers.centerLeftConstraintIdentifier || constraint.identifier == Constants.ConstraintIdentifiers.centerRightConstraintIdentifier {
                    constraint.isActive = false
                    
                    let centerButton = optionsBar.arrangedSubviews[1]
                    let centerCenterConstraint = underline.centerXAnchor.constraint(equalTo: centerButton.centerXAnchor)
                    centerCenterConstraint.identifier = Constants.ConstraintIdentifiers.centerCenterConstraintIdentifier
                    
                    NSLayoutConstraint.activate([centerCenterConstraint])
                }
            }
        case .right:
            for constraint in underline.superview!.constraints {
                if constraint.identifier == Constants.ConstraintIdentifiers.centerCenterConstraintIdentifier || constraint.identifier == Constants.ConstraintIdentifiers.centerLeftConstraintIdentifier {
                    constraint.isActive = false
                    
                    let rightButton = optionsBar.arrangedSubviews[2]
                    let centerRightConstraint = underline.centerXAnchor.constraint(equalTo: rightButton.centerXAnchor)
                    centerRightConstraint.identifier = Constants.ConstraintIdentifiers.centerRightConstraintIdentifier
                    
                    NSLayoutConstraint.activate([centerRightConstraint])
                }
            }
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: []) {
            self.view.layoutIfNeeded()
        }
    }
}

