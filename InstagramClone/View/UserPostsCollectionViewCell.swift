//
//  UserPostsCollectionViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 10/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class UserPostsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var postImageView: CustomImageView!
    
    var post : Post? {
        didSet{
            guard let imageUrl = post?.imageUrl else { return }
            postImageView.loadImage(with: imageUrl)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
