//
//  LoadingDots.swift
//  LoadingDotsAnimation
//
//  Created by QDSG on 2021/2/20.
//

import UIKit

enum LoadingDotsState {
    case loading
    case end
    
    var revserState: LoadingDotsState {
        switch self {
        case .loading: return .end
        case .end: return .loading
        }
    }
}

@IBDesignable
class LoadingDots: UIView {

    var view: UIView!
    
    @IBOutlet private weak var dotOne: UIImageView!
    @IBOutlet private weak var dotTwo: UIImageView!
    @IBOutlet private weak var dotThree: UIImageView!
    
    private var currentState: LoadingDotsState = .end
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        view = loadViewFromNib()
        registerNotifications()
        
        startAnimate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        view = loadViewFromNib()
        registerNotifications()
        
//        startAnimate()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension LoadingDots {
    func startAnimate() {
        switch currentState {
        case .end:
            alpha = 1.0
            currentState = currentState.revserState
            
            dotOne.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            dotTwo.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            dotThree.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            
            UIView.animate(withDuration: 0.6, delay: 0.0, options: [.repeat, .autoreverse]) {
                self.dotOne.transform = .identity
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.2, options: [.repeat, .autoreverse]) {
                self.dotTwo.transform = .identity
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.4, options: [.repeat, .autoreverse]) {
                self.dotThree.transform = .identity
            }
            
        case .loading:
            break
        }
    }
    
    func stopAnimate() {
        switch currentState {
        case .loading:
            alpha = 0.0
            currentState = currentState.revserState
        case .end:
            break
        }
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(UIApplicationDelegate.applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidBecomeActive(_ notification: Notification) {
        startAnimate()
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName(), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        return view
    }
    
    private func nibName() -> String {
        return String(describing: type(of: self))
    }
}
