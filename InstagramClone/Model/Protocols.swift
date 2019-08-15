//
//  Protocols.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 05/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation

protocol ProfileHeaderDelegate {
    func handleEditFollowTapped(for header: ProfileHeaderCell)
    func setUserStats(for header: ProfileHeaderCell)
    func handleFollowersTapped(for header: ProfileHeaderCell)
    func handleFollowingTapped(for header: ProfileHeaderCell)
}

protocol SearchTableCellDelegate {
    func handleFollowTapped(for cell: SearchTableViewCell)
}

protocol FeedCellDelegate {
    func handleUsernameTapped(for feedCell: HomeFeedCollectionViewCell)
    func handleOptionsTapped(for feedCell: HomeFeedCollectionViewCell)
    func handleLikeTapped(for feedCell: HomeFeedCollectionViewCell)
    func handleCommentTapped(for feedCell: HomeFeedCollectionViewCell)
    func handleConfigureLikeButton(for feedCell: HomeFeedCollectionViewCell)
    func handleShowLikes(for feedCell: HomeFeedCollectionViewCell)
}
