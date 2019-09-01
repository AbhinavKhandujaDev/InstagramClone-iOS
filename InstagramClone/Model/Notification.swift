//
//  Notification.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 22/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation

class Notification {
    
    enum NotifType: Int, Printable {
        case Like
        case Comment
        case Follow
        case CommentMention
        case PostMention
        
        var description: String {
            switch self {
            case .Like: return "Liked your post"
            case .Comment: return "Commented on your post"
            case .Follow: return "Followed you"
            case .CommentMention: return " mentioned you in a comment"
            case .PostMention: return " mentioned you in a post"
            }
        }
        
        init(index: Int) {
            switch index {
            case 0: self = .Like
            case 1: self = .Comment
            case 2: self = .Follow
            case 3: self = .CommentMention
            case 4: self = .PostMention
            default:self = .Like
            }
        }
        
    }
    
    var creationDate : Date!
    var uid : String!
    var postId : String?
    var post : Post?
    var user : User!
    var didCheck = false
    
    var notifType : NotifType!
    
    init(user: User, post : Post? = nil, dict: [String:Any]) {
        self.user = user
        
        if let post = post {
            self.post = post
        }
        
        if let creationDate = dict["creationDate"] as? Int {
            self.creationDate = Date(timeIntervalSince1970: TimeInterval(creationDate))
        }
        
        if let type = dict["type"] as? Int {
            self.notifType = NotifType(index: type)
        }
        
        if let uid = dict["uid"] as? String {
            self.uid = uid
        }
        
        if let postId = dict["postId"] as? String {
            self.postId = postId
        }
        
        if let checked = dict["checked"] as? Int {
            self.didCheck = (checked == 0) ? false : true
        }
    }
}
