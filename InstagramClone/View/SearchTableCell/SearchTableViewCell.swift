//
//  SearchTableViewCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 03/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var followBtn: UIButton!
    
    var delegate: SearchTableCellDelegate?
    
    var user : User? {
        didSet{
            usernameLabel.text = user?.username
            nameLabel.text = user?.name
            guard let imageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(with: imageUrl)
            
            configureFollowedBtn()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
    }
    
    func configureFollowedBtn() {
        followBtn.layer.cornerRadius = 5
        followBtn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        if user?.uid == loggedInUid {
            followBtn.isHidden = true
            return
        }
        
        user?.checkIfFollowed(completion: { (isFollowed) in
            if isFollowed {
                self.followBtn.setTitle("Following", for: .normal)
            }else {
                self.followBtn.setTitle("Follow", for: .normal)
            }
        })
    }
    
    @IBAction func followTapped(_ sender: UIButton) {
        delegate?.handleFollowTapped(for: self)
    }
}
