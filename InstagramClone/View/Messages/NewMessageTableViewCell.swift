//
//  NewMessageTableViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 26/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class NewMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    var user : User? {
        didSet {
            guard let user = user else { return }
            guard let imgUrl = user.profileImageUrl else { return }
            profileImageView.loadImage(with: imgUrl)
            setDetailLabel(username: user.username!, fullName: user.name!)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.roundCorners()
    }

    private func setDetailLabel(username: String, fullName: String) {
        let textAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let appendTextAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        detailLabel.setAttributedString(text: "\(username)\n", textAttributes: textAttrs, appendText: fullName, appendTextAttributes: appendTextAttrs)
    }

}
