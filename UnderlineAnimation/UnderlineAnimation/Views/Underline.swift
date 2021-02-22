//
//  Underline.swift
//  UnderlineAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

struct Constants {
    struct ColorPalette {
        static let green = UIColor(red: 0.00, green: 0.87, blue: 0.71, alpha: 1.0)
    }
    
    struct ConstraintIdentifiers {
        static let centerLeftConstraintIdentifier = "centerLeftConstraintIdentifier"
        static let centerCenterConstraintIdentifier = "centerCenterConstraintIdentifier"
        static let centerRightConstraintIdentifier = "centerRightConstraintIdentifier"
        static let widthConstraintIdentifier = "widthConstraintIdentifier"
    }
}

enum Side {
    case left
    case center
    case right
}

class Underline: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override class var requiresConstraintBasedLayout: Bool {
        return true
    }
    
    private func commonInit() {
        backgroundColor = Constants.ColorPalette.green
        translatesAutoresizingMaskIntoConstraints = false
    }
}
