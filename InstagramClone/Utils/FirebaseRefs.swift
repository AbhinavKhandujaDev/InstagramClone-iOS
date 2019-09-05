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

let usersRef = dbRef.child("users")

let postsRef = dbRef.child("posts")
let userFeedRef = dbRef.child("user-feed")
let userPostsRef = dbRef.child("user-posts")

let userLikesRef = dbRef.child("user-likes")
let postLikesRef = dbRef.child("post-likes")

let userFollowerRef = dbRef.child("user-follower")

let commentsRef = dbRef.child("comments")

let notificationsRef = dbRef.child("notifications")

let messagesRef = dbRef.child("messages")
let userMessagesRef = dbRef.child("user-messages")

let hashtagPostsRef = dbRef.child("hashtag-post")


let profileImageStorageRef = storageRef.child("profile_images")
