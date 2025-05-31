//
//  ViewController.swift
//  SSLPinning
//
//  Created by Sohanur Rahman on 20/11/24.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var afManager = AlamofireSSLPinning()
    
    var afTrustKitManager = AlamofireSSLPinningWithTrustKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
    }
        
    @IBAction func urlSessionButtonAction(_ sender: Any) {
        self.imageView.image = nil
        URLSessionSSLPinning().checkSSLPinning() { imgURL in
            self.imageView.loadImage(from: imgURL ?? "")
        }
    }
    
    @IBAction func alamofireButtonAction(_ sender: Any) {
        afManager.checkSSLPinning() { imgURL in
            self.imageView.loadImage(from: imgURL ?? "")
        }
    }
    
    @IBAction func alamofireAndTrustKitButtonAction(_ sender: Any) {
        afTrustKitManager.checkSSLPinning() { imgURL in
            self.imageView.loadImage(from: imgURL ?? "")
        }
    }
}
