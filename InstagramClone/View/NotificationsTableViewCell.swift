//
//  NotificationsTableViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 21/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var notifLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var postImageView: CustomImageView!
    
    var delegate : NotificationCellDelegate?
    
    var notification : Notification? {
        didSet{
            guard let username = notification?.user.username else { return }
            guard let userImage = notification?.user.profileImageUrl else { return }
            guard let description = notification?.notifType.description else { return }
            guard let date = notification?.creationDate else { return }
            profileImageView.loadImage(with: userImage)
            setNotifTypeView()
            setAttributedText(username: username, comment: description, date: date.timeToDisplay())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        followButton.layer.cornerRadius = 3
        
        postImageView.addTapGesture(target: self, selector: #selector(self.postTapped))
    }
    
    @objc private func postTapped() {
        delegate?.handlePostTapped(for: self)
    }
    
    private func setNotifTypeView() {
        
        if notification?.notifType == .Follow {
            followButton.isHidden = false
            postImageView.isHidden = true
            
            guard let user = notification?.user else { return }
            user.checkIfFollowed { (isFollowed) in
                if isFollowed {
                    self.followButton.setTitle("Following", for: .normal)
                }else {
                    self.followButton.setTitle("Follow", for: .normal)
                }
            }
        }else {
            followButton.isHidden = true
            postImageView.isHidden = false
            guard let imgUrl = notification?.post?.imageUrl else {return}
            postImageView.loadImage(with: imgUrl)
        }
    }
    
    private func setAttributedText(username: String, comment: String, date: String) {
        let textAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let commentAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)]
        let appendTextAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        let attributedText = NSMutableAttributedString(string: username, attributes: textAttrs)
        attributedText.append(NSAttributedString(string: " \(comment)", attributes: commentAttrs))
        attributedText.append(NSAttributedString(string: " \(date)", attributes: appendTextAttrs))
        
        notifLabel.attributedText = attributedText
    }
    
    @IBAction func folowBtnTapped(_ sender: UIButton) {
        delegate?.handleFollowTapped(for: self)
    }
}
