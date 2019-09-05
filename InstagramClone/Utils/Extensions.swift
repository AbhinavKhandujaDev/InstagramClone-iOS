//
//  Extensions.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

extension UIViewController {
    func getMentionedUser(username: String) {
        usersRef.observe(.childAdded) { (ss) in
            let uid = ss.key
            guard let dict = ss.value as? [String:Any] else {return}
            if username == dict["username"] as? String {
                dbRef.fetchUser(uid: uid, completion: { (user) in
                    self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
                        vc.user = user
                        return true
                    }, completion: nil)
                })
            }
        }
    }
    
    func uploadMentionedNotification(postId: String, text: String, isCommentMention: Bool) {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        
        let postType = isCommentMention ? commentMentionIntValue : postMentionIntValue
        
        for var word in words {
            if word.hasPrefix("@") {
                word = word.trimmingCharacters(in: .punctuationCharacters)
            
                //checking whether the user exists
                usersRef.observe(.childAdded) { (ss) in
                    let uid = ss.key
                    if currUser == uid {return}
                    usersRef.child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let dict = snapshot.value as? [String:Any] else {return}
                        if word == dict["username"] as? String {
                            let creationDate = Int(Date().timeIntervalSince1970)
                            let notifValues : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currUser, "type" : postType, "postId" : postId]
                            notificationsRef.child(uid).childByAutoId().updateChildValues(notifValues)
                        }
                    })
                }
            }
        }
    }
    
    func fetchPosts(databaseRef: DatabaseReference, currentKey: String?, initialCount: UInt, furtherCount: UInt, lastPostId: @escaping ((DataSnapshot)->()), postFetched: @escaping ((Post)->())) {
        if currentKey == nil {
            databaseRef.queryLimited(toLast: initialCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                guard let first = allObjects.first else {return}
                for object in allObjects {
                    let postId = object.key
                    self.fetchPost(postId: postId, completion: { (post) in
                        postFetched(post)
                    })
                }
                lastPostId(first)
            }
        }else {
            databaseRef.queryOrderedByKey().queryEnding(atValue: currentKey).queryLimited(toLast: furtherCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                guard let first = allObjects.first else {return}
                
                for object in allObjects {
                    let postId = object.key
                    if postId == currentKey {continue}
                    self.fetchPost(postId: postId, completion: { (post) in
                        postFetched(post)
                    })
                }
                lastPostId(first)
            }
        }
    }
    
    private func fetchPost(postId: String, completion: @escaping ((Post)->())) {
        dbRef.fetchPost(postId: postId) { (post) in
            guard let post = post else {return}
            completion(post)
        }
    }
    
    func fetchUsers(databaseRef: DatabaseReference, currentKey: String?, initialCount: UInt, furtherCount: UInt, lastUserId: @escaping ((DataSnapshot)->()), userFetched: @escaping ((User)->())) {
        if currentKey == nil {
            databaseRef.queryLimited(toLast: initialCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                guard let first = allObjects.first else {return}
                for object in allObjects {
                    let postId = object.key
                    self.fetchUser(userId: postId, completion: { (user) in
                        userFetched(user)
                    })
                }
                lastUserId(first)
            }
        }else {
            databaseRef.queryOrderedByKey().queryEnding(atValue: currentKey).queryLimited(toLast: furtherCount).observeSingleEvent(of: .value) { (snapshot) in
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else {return}
                guard let first = allObjects.first else {return}
                
                for object in allObjects {
                    let postId = object.key
                    if postId == currentKey {continue}
                    self.fetchUser(userId: postId, completion: { (user) in
                        userFetched(user)
                    })
                }
                lastUserId(first)
            }
        }
    }
    
    private func fetchUser(userId: String, completion: @escaping ((User)->())) {
        dbRef.fetchUser(uid: userId) { (user) in
            let user = user
            completion(user)
        }
    }
    
}

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 && width > 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 && height > 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func addTapGesture(target: Any, selector: Selector, tapsRequired: Int = 1) {
        let tapGest = UITapGestureRecognizer()
        tapGest.numberOfTapsRequired = tapsRequired
        tapGest.addTarget(target, action: selector)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGest)
    }
    
    func roundCorners(radius: CGFloat? = nil) {
        self.clipsToBounds = true
        self.layer.cornerRadius = (radius != nil) ? radius! : self.frame.height/2
    }
    
    func setGradientColor(colors: [CGColor] = [#colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1),#colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1),#colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)], at int: Int = 0) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = colors
        gradientLayer.locations = [0.0,0.5,1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: UInt32(int))
    }
    
}

extension Date {
    func timeAgoDisplay() -> String {
        let secondsAgo = Int(Date().timeIntervalSince(self))
        
        let minute = 60
        let hour = minute * 60
        let day = hour * 24
        let week = day * 7
        let month = week * 4
        
        if secondsAgo < 60 {
            return "\(secondsAgo) seconds ago"
        }else if secondsAgo < hour {
            return "\(secondsAgo/minute) minutes ago"
        }else if secondsAgo < day {
            return "\(secondsAgo/hour) hours ago"
        }else if secondsAgo < week {
            return "\(secondsAgo/day) days ago"
        }else if secondsAgo < month {
            return "\(secondsAgo/week) weeks ago"
        }else {
            return "\(secondsAgo/month) month(s) ago"
        }
    }
    
    func timeToDisplay() -> String {
        let dateFormatter = DateComponentsFormatter()
        dateFormatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        dateFormatter.maximumUnitCount = 1
        dateFormatter.unitsStyle = .abbreviated
        let now = Date()
        let dateToDisplay = dateFormatter.string(from: self, to: now)
        return ((dateToDisplay ?? "") + " ago")
    }
}

extension UIViewController {
    func pushTo<T:UIViewController>(vc: T.Type, storyboard: String = "Main", beforeCompletion: ((T)->(Bool))? = nil, completion:(()->())? = nil) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "\(T.self)") as! T
        let beforeActioncompleted = beforeCompletion?(controller)
        
        if beforeActioncompleted ?? true {
            if self.navigationController != nil {
                self.navigationController?.pushViewController(controller, animated: true)
            }else {
                self.present(controller, animated: true, completion: nil)
            }
        }
        completion?()
    }
    
    func presentVC(withIdentifier: String, storyboard: String = "Main", completion:(()->())? = nil) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: withIdentifier)
        self.present(controller, animated: true, completion: nil)
        completion?()
    }
}

extension UITextField {
    func setDefaultTextField(placeHolder: String) {
        self.clearButtonMode = .whileEditing
        self.placeholder = placeHolder
        self.backgroundColor = UIColor(white: 0, alpha: 0.03)
        self.borderStyle = .roundedRect
        self.font = UIFont.systemFont(ofSize: 14)
    }
    
    func addBottomBorder() {
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        self.layer.shadowRadius = 0
        self.layer.shadowOpacity = 1
    }
}

extension String {
    var isValidEmail : Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

extension UILabel {
    func setAttributedString(text: String? = "",textAttributes: [NSAttributedString.Key: Any]?, appendText: String? = "", appendTextAttributes: [NSAttributedString.Key: Any]?) {
        let attributedText = NSMutableAttributedString(string: text!, attributes: textAttributes)
        attributedText.append(NSAttributedString(string: appendText!, attributes: appendTextAttributes))
        self.attributedText = attributedText
    }
}

extension DatabaseReference {
    func fetchPost(postId: String, completion: @escaping((Post?)->())) {
        var dict : [String:Any] = [:]
        var post : Post?
        var count = 0
        postsRef.child(postId).observe(.childAdded, with: { (ss) in
            dict[ss.key] = ss.value
            post = Post(postId: postId, dict: dict)
            count += 1
            if count == 5 {
                completion(post)
            }
        })
    }
    
    func fetchUser(uid: String, completion: @escaping((User)->())) {
        usersRef.child(uid).observeSingleEvent(of: .value) { (ss) in
            guard let dict = ss.value as? [String:AnyObject] else {return}
            let user = User(uid: uid, details: dict)
            completion(user)
        }
    }
}
