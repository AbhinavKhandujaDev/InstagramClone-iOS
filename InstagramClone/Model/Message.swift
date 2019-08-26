//
//  Message.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 26/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation

class Message {
    var messageText : String!
    var fromId : String!
    var toId : String!
    var creationDate : Date!
    
    init(dictionary: [String:Any]) {
        if let messageText = dictionary["messageText"] as? String {
            self.messageText = messageText
        }
        
        if let fromId = dictionary["fromId"] as? String {
            self.fromId = fromId
        }
        
        if let toId = dictionary["toId"] as? String {
            self.toId = toId
        }
        
        if let creationDate = dictionary["creationDate"] as? Int {
            self.creationDate = Date(timeIntervalSince1970: TimeInterval(creationDate))
        }
    }
    
    func getChatPartnerId() -> String {
        guard let currUser = loggedInUid else { return "nil" }
        if fromId == currUser {
            return toId
        }else {
            return fromId
        }
    }
}
