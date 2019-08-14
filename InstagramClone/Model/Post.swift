//
//  Post.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 09/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation

class Post {
    var caption : String!
    var createdAt : Date!
    var imageUrl : String!
    var likes : Int!
    var ownerUid : String!
    var postId : String!
    
    init(postId: String, dict : [String:Any]) {
        self.postId = postId
        if let date = dict["createdAt"] as? Int {
            self.createdAt = Date(timeIntervalSince1970: TimeInterval(date))
        }
        if let caption = dict["caption"] as? String {
            self.caption = caption
        }
        if let url = dict["imageUrl"] as? String {
            self.imageUrl = url
        }
        if let likes = dict["likes"] as? Int {
            self.likes = likes
        }
        if let ownerUid = dict["uid"] as? String {
            self.ownerUid = ownerUid
        }
    }
}
