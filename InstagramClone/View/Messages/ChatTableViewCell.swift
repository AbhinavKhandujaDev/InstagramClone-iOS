//
//  ChatTableViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 26/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var bubbleViewLeftAnchor: NSLayoutConstraint!
    @IBOutlet weak var bubbleViewRightAnchor: NSLayoutConstraint!
    
    
    @IBOutlet weak var profileImgViewLeftAnchor: NSLayoutConstraint!
    @IBOutlet weak var profileImgViewRightAnchor: NSLayoutConstraint!
    
    var message: Message? {
        didSet{
            guard let message = message else { return }
            self.messageLabel.text = message.messageText
            loadProfileImage()
            setConstraints()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.roundCorners()
        bubbleView.roundCorners(radius: 10)
    }
    
    private func loadProfileImage() {
        guard let currUser = loggedInUid else { return }
        guard let message = message else { return }
        var uid = message.getChatPartnerId()
        
        if currUser == message.fromId {
            uid = currUser
        }
        dbRef.fetchUser(uid: uid) { (user) in
            guard let url = user.profileImageUrl else {return}
            self.profileImageView.loadImage(with: url)
        }
    }
    
    private func setConstraints() {
        guard let message = message else { return }
        guard let currUser = loggedInUid else { return }
        bubbleViewLeftAnchor?.isActive = currUser == message.fromId ? false : true
        bubbleViewRightAnchor?.isActive = currUser == message.fromId ? true : false
        
        profileImgViewLeftAnchor?.isActive = currUser == message.fromId ? false : true
        profileImgViewRightAnchor?.isActive = currUser == message.fromId ? true : false
        
        if bubbleViewLeftAnchor != nil && bubbleViewLeftAnchor.isActive && profileImgViewLeftAnchor != nil && profileImgViewLeftAnchor.isActive {
            bubbleViewLeftAnchor.constant = 8
            profileImgViewLeftAnchor.constant = 8
            bubbleView.backgroundColor = UIColor.rgb(red: 240, green: 240, blue: 240, alpha: 1)
            messageLabel.textColor = .black
        }
        
        if bubbleViewRightAnchor != nil && bubbleViewRightAnchor.isActive && profileImgViewRightAnchor != nil && profileImgViewRightAnchor.isActive {
            bubbleViewRightAnchor.constant = 8
            profileImgViewRightAnchor.constant = 8
            bubbleView.backgroundColor = UIColor.rgb(red: 0, green: 137, blue: 249, alpha: 1)
            messageLabel.textColor = .white
        }
    }
    
}
