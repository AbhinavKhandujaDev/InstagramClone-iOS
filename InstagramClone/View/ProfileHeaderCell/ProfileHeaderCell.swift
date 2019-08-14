//
//  ProfileHeaderCell.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 02/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class ProfileHeaderCell: UICollectionViewCell {
    
    @IBOutlet weak var profileImageView: CustomImageView!
    
    @IBOutlet weak var editProfileBtn: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var postsLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    
    var delegate : ProfileHeaderDelegate?
    
    var user: User? {
        didSet{
            configureEditProfBtn()
            nameLabel.text = user?.name
            guard let imageUrl = user?.profileImageUrl else {return}
            profileImageView.loadImage(with: imageUrl)
            delegate?.setUserStats(for: self)
        }
    }
    
    fileprivate let gridButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "grid"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    fileprivate let listButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    fileprivate let bookmarkButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setEditProfileBtn()
        
        nameLabel.text = ""
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        
        let textAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let appendTextAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        postsLabel.setAttributedString(text: "0\n", textAttributes: textAttrs, appendText: "posts", appendTextAttributes: appendTextAttrs)
        
        followersLabel.addTapGesture(target: self, selector: #selector(self.followersTapped))
        followingLabel.addTapGesture(target: self, selector: #selector(self.followingTapped))
    
        setBottomOptions()
    }
    
    @objc func followersTapped() {
        delegate?.handleFollowersTapped(for: self)
    }
    
    @objc func followingTapped() {
        delegate?.handleFollowingTapped(for: self)
    }
    
    fileprivate func setEditProfileBtn() {
        editProfileBtn.layer.cornerRadius = 5
        editProfileBtn.layer.borderColor = UIColor.lightGray.cgColor
        editProfileBtn.layer.borderWidth = 0.5
    }
    
    fileprivate func setBottomOptions() {
        let topDividerView = UIView()
        topDividerView.backgroundColor = .lightGray
        
        let bottomDividerView = UIView()
        bottomDividerView.backgroundColor = .lightGray
        
        let stackView = UIStackView(arrangedSubviews: [gridButton, listButton, bookmarkButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(topDividerView)
        addSubview(stackView)
        addSubview(bottomDividerView)
        
        stackView.anchor(top: nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0.5, paddingRight: 0, width: 0, height: 50)
        
        topDividerView.anchor(top: stackView.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        bottomDividerView.anchor(top: stackView.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
    }
    
    fileprivate func configureEditProfBtn() {
        if user?.uid != loggedInUid && user != nil {
            editProfileBtn.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            editProfileBtn.setTitleColor(UIColor.white, for: .normal)
            user?.checkIfFollowed(completion: { [weak self] (isFollowed) in
                let title = isFollowed ? "Following" : "Follow"
                self?.editProfileBtn.setTitle(title, for: .normal)
            })
        }
    }
    
    @IBAction func editProfileBtnTapped(_ sender: UIButton) {
        delegate?.handleEditFollowTapped(for: self)
    }
}
