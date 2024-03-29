//
//  Post.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 09/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation
import Firebase

class Post {
    var caption : String!
    var createdAt : Date!
    var imageUrl : String!
    var likes : Int!
    var ownerUid : String!
    var postId : String!
    var didLike = false
    
    var user : User!
    
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
            dbRef.fetchUser(uid: ownerUid) { (user) in
                self.user = user
            }
        }
        
    }
    
    func adjustLikes(addLike: Bool, completion: @escaping((Int)->())) {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        if addLike {
            //update like from user-like structure
            let value = [postId : 1]
            userLikesRef.child(currentUserId).updateChildValues(value) { (error, ref) in
                self.sendLikeNotifToServer()
                //update like count
                postLikesRef.child(self.postId).updateChildValues([currentUserId : 1]) { (error, ref) in
                    self.likes += 1
                    self.didLike = true
                    completion(self.likes)
                    postsRef.child(self.postId).updateChildValues(["likes" : self.likes])
                }
            }
        }else {
            userLikesRef.child(currentUserId).child(postId).observeSingleEvent(of: .value) { (snapshot) in
                let notificationId = snapshot.key
                notificationsRef.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (error, ref) in
                    //remove like from user-like structure
                    userLikesRef.child(currentUserId).child(self.postId).removeValue { (error, ref) in
                        
                        //remove like from post-like structure
                        postLikesRef.child(self.postId).child(currentUserId).removeValue { (error, ref) in
                            guard self.likes > 0 else {return}
                            self.likes -= 1
                            self.didLike = false
                            completion(self.likes)
                            postsRef.child(self.postId).updateChildValues(["likes" : self.likes])
                        }
                    }
                })
            }
        }
    }
    
    private func sendLikeNotifToServer() {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        let notifRef = notificationsRef.child(self.ownerUid).childByAutoId()
        userLikesRef.child(currUser).child(self.postId).setValue(notifRef.key)
        if currUser == self.ownerUid {return}
        let values : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currUser, "type" : likeIntValue, "postId" : postId]
        notifRef.updateChildValues(values)
    }
    
    func deletePost() {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        
        //remove from storage
        Storage.storage().reference(forURL: self.imageUrl).delete(completion: nil)
        
        //deleting from other users feed by looking users in user-follower
        userFollowerRef.child(currUser).observe(.childAdded) { (snapshot) in
            let followerUid = snapshot.key
            userFeedRef.child(followerUid).child(self.postId).removeValue()
        }
        
        //deleting from own user-feed structure
        userFeedRef.child(currUser).child(self.postId).removeValue()
        
        //deleting from userPostsRef
        userPostsRef.child(currUser).child(self.postId).removeValue()
        
        //deleting from postLikesRef, userLikesRef and notificationsRef by accessing users in postLikesRef of the post
        postLikesRef.child(postId).observe(.childAdded) { (snapshot) in
            let userId = snapshot.key
            userLikesRef.child(userId).child(self.postId).observe(.childAdded, with: { (snapshot) in
                
                //removing post from notifications
                guard let notificationId = snapshot.value as? String else {return}
                notificationsRef.child(self.ownerUid).child(notificationId).removeValue(completionBlock: { (err, ref) in
                    postLikesRef.child(self.postId).removeValue()
                    userLikesRef.child(userId).child(self.postId).removeValue()
                })
            })
        }
        
        //removing from hashtagPostsRef
        let words = caption.components(separatedBy: .whitespacesAndNewlines)
        
        for var word in words {
            if word.hasPrefix("#") {
                word = word.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .symbols)
                hashtagPostsRef.child(word).child(self.postId).removeValue()
            }
        }
        
        commentsRef.child(self.postId).removeValue()
        
        postsRef.child(self.postId).removeValue()
    }
}
