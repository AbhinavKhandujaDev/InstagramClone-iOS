//
//  CommentTableViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 21/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var commentLabel: UILabel!
    
    var comment : Comment? {
        didSet{
            guard let comment = comment else { return }
            guard let user = comment.user else { return }
            guard let imgUrl = user.profileImageUrl else { return }
            guard let username = user.username else { return }
            guard let commentText = comment.commentText else { return }
            profileImageView.loadImage(with: imgUrl)
            setAttributedText(username: username, comment: commentText, date: comment.creationDate.timeToDisplay())
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
    }

    private func setAttributedText(username: String, comment: String, date: String) {
        let textAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 12)]
        let appendTextAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        let attributedText = NSMutableAttributedString(string: username, attributes: textAttrs)
        attributedText.append(NSAttributedString(string: " \(comment)", attributes: textAttrs))
        attributedText.append(NSAttributedString(string: " \(date)", attributes: appendTextAttrs))
        
        commentLabel.attributedText = attributedText
    }

}
