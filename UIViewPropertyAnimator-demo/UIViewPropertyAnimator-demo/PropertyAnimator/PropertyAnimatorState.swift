//
//  PropertyAnimatorState.swift
//  UIViewPropertyAnimator-demo
//
//  Created by QDSG on 2021/2/6.
//

import Foundation

enum PropertyAnimatorState {
    case closed
    case open
}

extension PropertyAnimatorState {
    var opposite: PropertyAnimatorState {
        switch self {
        case .closed: return .open
        case .open:   return .closed
        }
    }
}
