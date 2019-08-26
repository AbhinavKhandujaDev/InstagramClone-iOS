//
//  FirebaseRefs.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 09/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import Foundation
import Firebase

let dbRef = Database.database().reference()
let storageRef = Storage.storage().reference()
let loggedInUid = Auth.auth().currentUser?.uid

let usersRef = dbRef.child("users")

let postRef = dbRef.child("posts")
let userFeedRef = dbRef.child("user-feed")

let userLikesRef = dbRef.child("user-likes")
let postLikesRef = dbRef.child("post-likes")

let commentsRef = dbRef.child("comments")

let notificationsRef = dbRef.child("notifications")
//let unreadNotifRef = dbRef.child("unread-notifications")

let messagesRef = dbRef.child("messages")
let userMessagesRef = dbRef.child("user-messages")

let likeIntValue = 0
let commentIntValue = 1
let followIntValue = 2


