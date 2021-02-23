//
//  ViewController.swift
//  GifAnimation
//
//  Created by QDSG on 2021/2/23.
//

import UIKit
import SwiftGifOrigin

struct Constants {
    struct Gifs {
        static let catVideo = "cat-video"
    }
}

class ViewController: UIViewController {
    
    @IBOutlet private weak var gifImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        gifImageView.loadGif(name: Constants.Gifs.catVideo)
    }

    override var prefersStatusBarHidden: Bool { return true }
}

