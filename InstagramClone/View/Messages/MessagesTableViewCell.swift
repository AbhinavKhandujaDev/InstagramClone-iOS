//
//  MessagesTableViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 25/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class MessagesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: CustomImageView!
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    var identifier : String!
    
    var message : Message? {
        didSet{
            guard let message = message else { return }
            timeLabel.text = message.creationDate.timeToDisplay()
            configureUserData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: identifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.roundCorners()
    }
    
    fileprivate func setDetailLabel(username: String, messageText: String) {
        let textAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let appendTextAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        detailLabel.setAttributedString(text: "\(username)\n", textAttributes: textAttrs, appendText: "\(messageText)", appendTextAttributes: appendTextAttrs)
    }
    
    private func configureUserData() {
        guard let partnerId = message?.getChatPartnerId() else {return}
        dbRef.fetchUser(uid: partnerId) { (user) in
            guard let url = user.profileImageUrl else {return}
            guard let username = user.username else {return}
            guard let messageText = self.message?.messageText else {return}
            self.profileImageView.loadImage(with: url)
            self.setDetailLabel(username: username, messageText: messageText)
        }
    }

}
