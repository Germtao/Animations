//
//  ViewController.swift
//  ProgressAnimation
//
//  Created by QDSG on 2021/2/22.
//

import UIKit

class ViewController: UIViewController {
    
    let rmb = RMB()
    
    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureProgressView()
    }

    @IBOutlet private weak var progressView: ProgressView!
    @IBOutlet private weak var progressPercentageLabel: UILabel!
    @IBOutlet private weak var incrementProgressButton: UIButton!
    
    private func configureProgressView() {
        progressView.curValue = rmb.ouncesDrank
        progressView.range = rmb.totalOunces
    }
    
    @IBAction private func incrementProgress(_ sender: UIButton) {
        guard progressView.curValue < rmb.totalOunces else { return }
        
        let eightOunceCup: CGFloat = 8.0
        progressView.curValue += eightOunceCup
        
        let percentage = Double(progressView.curValue / rmb.totalOunces)
        progressPercentageLabel.text = numberAsPercentage(percentage)
    }
    
    private func numberAsPercentage(_ number: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.percentSymbol = ""
        return formatter.string(from: NSNumber(value: number)) ?? ""
    }
}

