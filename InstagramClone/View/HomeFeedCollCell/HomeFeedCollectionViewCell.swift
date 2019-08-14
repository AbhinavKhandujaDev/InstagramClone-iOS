//
//  HomeFeedCollectionViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 10/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class HomeFeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImgView: CustomImageView!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var postImageView: CustomImageView!
    
    var delegate : FeedCellDelegate?
    
    var post : Post? {
        didSet{
            postImageView.loadImage(with: (post?.imageUrl)!)
            likesLabel.text = String(describing: post?.likes!)
            captionLabel.text = post?.caption
            timeLabel.text = String(describing: post?.createdAt!)
            
            guard let owner = post?.ownerUid else {return}
            dbRef.child("users").child(owner).observeSingleEvent(of: .value) { (snapshot) in
                guard let ss = snapshot.value as? [String:Any] else {return}
                guard let username = ss["username"] as? String else {return}
                self.profileImgView.loadImage(with: ss["profileImageUrl"] as! String)
                self.usernameLabel.setTitle(username, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
    }
    @IBAction func usernameTapped(_ sender: UIButton) {
        delegate?.handleUsernameTapped(for: self)
    }
    @IBAction func optionsTapped(_ sender: UIButton) {
        delegate?.handleOptionsTapped(for: self)
    }
    @IBAction func likeTapped(_ sender: UIButton) {
        delegate?.handleLikeTapped(for: self)
    }
    @IBAction func commentTapped(_ sender: UIButton) {
        delegate?.handleCommentTapped(for: self)
    }
}
