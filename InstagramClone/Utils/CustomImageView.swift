//
//  CustomImageView.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 10/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

var imageCache = [String : UIImage]()

class CustomImageView: UIImageView {
    
    var lastImageUrl : String?
    
    func loadImage(with urlString: String) {
        
        self.image = nil
        lastImageUrl = urlString
        
        if let cacheImage = imageCache[urlString] {
            self.image = cacheImage
            return
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("failed to load image ",error.localizedDescription)
            }
            
            if self.lastImageUrl != url.absoluteString {return}
            
            guard let imageData = data else {return}
            
            let photoImage = UIImage(data: imageData)
            
            imageCache[urlString] = photoImage
            
            DispatchQueue.main.sync {
                self.image = photoImage
            }
        }.resume()
    }
}
