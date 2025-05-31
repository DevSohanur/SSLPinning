//
//  ImageLoader.swift
//  SSLPinning
//
//  Created by Sohanur Rahman on 31/5/25.
//

import UIKit

extension UIImageView {
    
    func loadImage(from urlString: String) {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL string.")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Image download error: \(error.localizedDescription)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to load image from data.")
                return
            }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}
