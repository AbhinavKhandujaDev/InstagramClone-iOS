//
//  HomeFeedCollectionViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 10/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import ActiveLabel

class HomeFeedCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var profileImgView: CustomImageView!
    @IBOutlet weak var likesLabel: UILabel!
    @IBOutlet weak var captionLabel: ActiveLabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var optionsBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var messagesBtn: UIButton!
    
    @IBOutlet weak var postImageView: CustomImageView!
    
    var delegate : FeedCellDelegate?
    
    var post : Post? {
        didSet{
            guard let date = post?.createdAt else { return }
            postImageView.loadImage(with: (post?.imageUrl)!)
            likesLabel.text = String(describing: post?.likes ?? 0) + " " + "likes"
            captionLabel.text = post?.caption
            timeLabel.text = date.timeAgoDisplay()
            
            guard let owner = post?.ownerUid else {return}
            usersRef.child(owner).observeSingleEvent(of: .value) { (snapshot) in
                guard let ss = snapshot.value as? [String:Any] else {return}
                guard let username = ss["username"] as? String else {return}
                self.profileImgView.loadImage(with: ss["profileImageUrl"] as! String)
                self.usernameLabel.setTitle(username, for: .normal)
            }
            captionLabel.enabledTypes = [.hashtag, .mention, .url]
            delegate?.handleConfigureLikeButton(for: self)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postImageView.addTapGesture(target: self, selector: #selector(self.doubleTapToLike(sender:)), tapsRequired: 2)
        profileImgView.layer.cornerRadius = profileImgView.frame.height/2
        likesLabel.addTapGesture(target: self, selector: #selector(self.likesLabelTapped(sender:)))
    }
    
    @objc private func doubleTapToLike(sender: UITapGestureRecognizer) {
        delegate?.handleLikeTapped(for: self)
    }
    
    @objc private func likesLabelTapped(sender: UITapGestureRecognizer) {
        delegate?.handleShowLikes(for: self)
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
    @IBAction func messagesTapped(_ sender: UIButton) {
        delegate?.handleShowMessages(for: self)
    }
}
