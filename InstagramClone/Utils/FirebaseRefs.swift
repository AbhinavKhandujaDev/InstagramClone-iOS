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
let postRef = dbRef.child("posts")
let userFeedRef = dbRef.child("user-feed")

