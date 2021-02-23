//
//  ViewController.swift
//  SecretTextAnimation
//
//  Created by TT on 2021/2/22.
//

import UIKit

struct Constants {
    struct Images {
        static let one = "one"
        static let two = "two"
        static let three = "three"
        static let four = "four"
        static let five = "five"
        static let six = "six"
        static let seven = "seven"
        static let eight = "eight"
        static let nine = "nine"
        static let ten = "ten"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet private weak var backgroundImageView: UIImageView!
    
    var quoteLabel: FadingLabel!
    var animationDuration: TimeInterval = 1.0
    var switchingInterval: TimeInterval = 3.0
    var currentIndex = 0
    
    let quotes = [
        Quote(quote: "\"The unexamined life is not worth living.\"", author: "Socrates", image: UIImage(named: Constants.Images.one)!),
        Quote(quote: "\"The most beautiful thing we can experience is the mysterious. It is the source of all true art and science.\"", author: "Albert Einstein", image: UIImage(named: Constants.Images.two)!),
        Quote(quote: "\"I do not steal victory.\"", author: "Alexander the Great", image: UIImage(named: Constants.Images.three)!),
        Quote(quote: "\"The key to immortality is first living a life worth remembering.\"", author: "Bruce Lee", image: UIImage(named: Constants.Images.four)!),
        Quote(quote: "\"Decide... whether or not the goal is worth the risks involved. If it is, stop worrying....\"", author: "Amelia Earhart", image: UIImage(named: Constants.Images.five)!),
        Quote(quote: "\"I've failed over and over and over again in my life and that is why I succeed.\"", author: "Michael Jordan", image: UIImage(named: Constants.Images.six)!),
        Quote(quote: "\"Kind words can be short and easy to speak, but their echoes are truly endless.\"", author: "Mother Teresa", image: UIImage(named: Constants.Images.seven)!),
        Quote(quote: "\"Live as if you were to die tomorrow; learn as if you were to live forever.\"", author: "Mahatma Gandhi", image: UIImage(named: Constants.Images.eight)!),
        Quote(quote: "\"Somewhere, something incredible is waiting to be known.\"", author: "Carl Sagan", image: UIImage(named: Constants.Images.nine)!),
        Quote(quote: "\"It is not death that a man should fear, but he should fear never beginning to live.\"", author: "Marcus Aurelius", image: UIImage(named: Constants.Images.ten)!)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupBackgroundImage()
        setupCharacterLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        animateBackgroundImageView()
    }

    override var prefersStatusBarHidden: Bool { return true }
}

extension ViewController {
    private func setupCharacterLabel() {
        quoteLabel = FadingLabel(frame: CGRect(x: 20, y: 20, width: 100, height: 100))
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.textAlignment = .center
        quoteLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 30)
        quoteLabel.textColor = UIColor.white
        quoteLabel.lineBreakMode = .byWordWrapping
        quoteLabel.numberOfLines = 0
        
        view.addSubview(quoteLabel)
        
        NSLayoutConstraint.activate([
            quoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            quoteLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            quoteLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 1.25)
        ])
    }
    
    private func setupBackgroundImage() {
        backgroundImageView.image = quotes[currentIndex].image
    }
    
    private func switchQuote() {
        quoteLabel.text = ""
        quoteLabel.text = quotes[currentIndex].quote + "\n\n" + quotes[currentIndex].author
    }
    
    private func animateBackgroundImageView() {
        switchQuote()
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animationDuration)
        CATransaction.setCompletionBlock {
            let delay = DispatchTime.now() + self.switchingInterval
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.animateBackgroundImageView()
            }
        }
        
        let transition = CATransition()
        transition.type = .fade
        
        backgroundImageView.layer.add(transition, forKey: kCATransition)
        setupBackgroundImage()
        CATransaction.commit()
        
        currentIndex = currentIndex < quotes.count - 1 ? currentIndex + 1 : 0
    }
}

