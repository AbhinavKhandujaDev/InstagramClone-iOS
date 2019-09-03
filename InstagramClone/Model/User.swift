//
//  Profile.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 03/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation
import Firebase

class User {
    var name: String?
    var username : String?
    var profileImageUrl : String?
    var uid : String?
    var isFollowed : Bool = false
    
    enum FollowUnfollow : String {
        case following = "user-following"
        case follower = "user-follower"
    }
    
    init(uid: String, details: [String:AnyObject]) {
        self.uid = uid
        
        if let username = details["username"] as? String {
            self.username = username
        }
        if let name = details["name"] as? String {
            self.name = name
        }
        if let profileImageUrl = details["profileImageUrl"] as? String {
            self.profileImageUrl = profileImageUrl
        }
    }
    
    func follow(completion: @escaping ((Bool)->())) {
        guard let loggedInUid = Auth.auth().currentUser?.uid else { return }
        guard let searchedUid = uid else {return}
        
        dbRef.child(FollowUnfollow.following.rawValue).child(loggedInUid).updateChildValues([searchedUid : 1]) { [weak self] (error, ref) in
            if error != nil {
                completion(false)
                return
            }
            self?.uploadFollowNotifToServer()
            dbRef.child(FollowUnfollow.follower.rawValue).child(searchedUid).updateChildValues([loggedInUid : 1]) { (error,ref) in
                self?.addPosts(followedUser: searchedUid, loggedInUser: loggedInUid)
                self?.isFollowed = true
                completion(true)
            }
        }
    }
    
    func unfollow(completion: @escaping ((Bool)->())) {
        guard let loggedInUid = Auth.auth().currentUser?.uid else { return }
        guard let searchedUid = uid else {return}
        dbRef.child(FollowUnfollow.following.rawValue).child(loggedInUid).child(searchedUid).removeValue { [weak self] (error, ref) in
            if error != nil {
                completion(false)
                return
            }
            dbRef.child(FollowUnfollow.follower.rawValue).child(searchedUid).child(loggedInUid).removeValue(completionBlock: { (error, ref) in
                self?.removePosts(followedUser: searchedUid, loggedInUser: loggedInUid)
                self?.isFollowed = false
                completion(true)
            })
        }
    }
    
    func checkIfFollowed(completion: @escaping ((Bool)->())) {
        guard let loggedInUid = Auth.auth().currentUser?.uid else { return }
        guard let searchedUid = uid else {return}
        dbRef.child(FollowUnfollow.following.rawValue).child(loggedInUid).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(searchedUid) {
                self.isFollowed = true
            }else {
                self.isFollowed = false
            }
            completion(self.isFollowed)
        }
    }
    
    func uploadFollowNotifToServer() {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        if currUser == uid {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let values : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currUser, "type" : followIntValue]
        
        notificationsRef.child(uid!).childByAutoId().updateChildValues(values)
    }
    
    private func addPosts(followedUser: String, loggedInUser: String) {
        userPostsRef.child(followedUser).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {return}
            userFeedRef.child(loggedInUser).updateChildValues(dict)
        }
    }
    
    private func removePosts(followedUser: String, loggedInUser: String) {
        userPostsRef.child(followedUser).observeSingleEvent(of: .value) { (snapshot) in
            guard let dict = snapshot.value as? [String:Any] else {return}
            for key in dict.keys {
                userFeedRef.child(loggedInUser).child(key).removeValue()
            }
        }
    }
}
