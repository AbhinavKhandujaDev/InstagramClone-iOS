//
//  Comment.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 18/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation

struct Comment {
    var uid : String!
    var creationDate : Date!
    var commentText : String!
    var user : User?
    
    init(user: User, dictionary: [String:Any]) {
        self.user = user
        
        if let commentText = dictionary["commentText"] as? String {
            self.commentText = commentText
        }
        
        if let creationDate = dictionary["creationDate"] as? Int {
            self.creationDate = Date(timeIntervalSince1970: TimeInterval(creationDate))
        }
    }
}
