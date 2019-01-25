//
//  ViewController.swift
//  LoginScreen
//
//  Created by TT on 2019/1/24.
//  Copyright © 2019年 SwifterTT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cloudView1: UIImageView!
    @IBOutlet weak var cloudView2: UIImageView!
    @IBOutlet weak var cloudView3: UIImageView!
    @IBOutlet weak var cloudView4: UIImageView!
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!

    let spinner = UIActivityIndicatorView(style: .whiteLarge)
    let statusView = UIImageView(image: UIImage(named: "bg_status"))
    let messages = ["连接中...", "授权中...", "发送凭证...", "失败..."]
    let statusLabel = UILabel()
    
    var statusPosition = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = 8.0
        
        spinner.frame = CGRect(x: -20.0, y: 6.0, width: 20.0, height: 20.0)
        spinner.startAnimating()
        spinner.alpha = 0.0
        loginBtn.addSubview(spinner)
        
        statusView.isHidden = true
        statusView.center = loginBtn.center
        view.addSubview(statusView)
        
        statusLabel.frame = CGRect(x: 0, y: 0, width: statusView.frame.size.width, height: statusView.frame.size.height)
        statusLabel.font = UIFont(name: "HelveticaNeue", size: 18.0)
        statusLabel.textColor = UIColor(red: 0.89, green: 0.38, blue: 0.0, alpha: 1.0)
        statusLabel.textAlignment = .center
        statusView.addSubview(statusLabel)
        
        statusPosition = statusView.center
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTF.center.x -= view.bounds.width
        passwordTF.center.x -= view.bounds.width
        
        cloudView1.alpha = 0.0
        cloudView2.alpha = 0.0
        cloudView3.alpha = 0.0
        cloudView4.alpha = 0.0
        
        loginBtn.center.y += 30
        loginBtn.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.usernameTF.center.x += self.view.bounds.width
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: [], animations: {
            self.passwordTF.center.x += self.view.bounds.width
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations: {
            self.cloudView1.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.7, options: [], animations: {
            self.cloudView2.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 0.9, options: [], animations: {
            self.cloudView3.alpha = 1.0
        }, completion: nil)
        UIView.animate(withDuration: 0.5, delay: 1.1, options: [], animations: {
            self.cloudView4.alpha = 1.0
        }, completion: nil)
        
        UIView.animate(withDuration: 0.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginBtn.center.y -= 30.0
            self.loginBtn.alpha = 1.0
        }, completion: nil)
        
        animateCloud(cloudView1)
        animateCloud(cloudView2)
        animateCloud(cloudView3)
        animateCloud(cloudView4)
    }
    
    // MARK: - Action
    @IBAction func login(_ sender: UIButton) {
        loginBtn.isEnabled = false
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginBtn.bounds.size.width += 80.0
        }) { (_) in
            self.showMessage(index: 0)
        }
        
        UIView.animate(withDuration: 0.33, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.0, options: [], animations: {
            self.loginBtn.center.y += 60.0
            self.loginBtn.backgroundColor = UIColor(red: 0.85, green: 0.83, blue: 0.45, alpha: 1.0)
            self.spinner.center = CGPoint(x: 40.0, y: self.loginBtn.frame.size.height * 0.5)
            self.spinner.alpha = 1.0
        }, completion: nil)
    }
}

extension ViewController {
    /// 云动画
    private func animateCloud(_ cloudView: UIImageView) {
        let cloudSpeed = view.frame.size.width / 60.0
        let duration = (view.frame.size.width - cloudView.frame.origin.x) / cloudSpeed
        UIView.animate(withDuration: TimeInterval(duration), delay: 0.0, options: .curveLinear, animations: {
            cloudView.frame.origin.x = self.view.frame.size.width
        }) { (_) in
            cloudView.frame.origin.x = -cloudView.frame.origin.x
            self.animateCloud(cloudView)
        }
    }
    
    /// 状态信息显示
    private func showMessage(index: Int) {
        statusLabel.text = messages[index]
        
        UIView.transition(with: statusView, duration: 0.33, options: [.curveEaseOut, .transitionCurlDown], animations: {
            self.statusView.isHidden = false
        }) { (_) in
            self.delay(2.0, completion: {
                if index < self.messages.count - 1 {
                    self.removeMessage(index: index)
                } else {
                    self.resetForm()
                }
            })
        }
    }
    
    /// 状态信息清除
    private func removeMessage(index: Int) {
        UIView.animate(withDuration: 0.33, delay: 0.0, options: [], animations: {
            self.statusView.center.x += self.view.frame.size.width
        }) { (_) in
            self.statusView.isHidden = true
            self.statusView.center = self.statusPosition
            
            self.showMessage(index: index + 1)
        }
    }
    
    /// 信息标签和登录按钮状态恢复
    private func resetForm() {
        // 状态信息标签消失动画
        UIView.transition(with: statusView, duration: 0.2, options: .transitionFlipFromTop, animations: {
            self.statusView.isHidden = true
            self.statusView.center = self.statusPosition
        }, completion: nil)
        
        // 登录按钮和菊花状态恢复动画
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
            self.spinner.center = CGPoint(x: -20.0, y: 16.0)
            self.spinner.alpha = 0.0
            self.loginBtn.backgroundColor = UIColor(red: 0.63, green: 0.84, blue: 0.35, alpha: 1.0)
            self.loginBtn.bounds.size.width -= 80.0
            self.loginBtn.center.y -= 60.0
        }) { (_) in
            self.loginBtn.isEnabled = true
        }
    }
    
    private func delay(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
    }
}

