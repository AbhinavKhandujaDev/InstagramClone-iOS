//
//  CommentViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 18/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UITableViewController {
    
    private let comentCellIdentifier = "commentTableCell"
    private let padding : CGFloat = 0
    
    var post : Post!
    
    var comments = [Comment]()
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cView = CommentInputAccessoryView(frame: frame)
        cView.delegate = self
        cView.backgroundColor = UIColor.white
        return cView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchComments()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override var inputAccessoryView: UIView? {
        get {
            return containerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        containerView.commentTextView.resignFirstResponder()
    }

    private func fetchComments() {
        commentsRef.child(post.postId).observe(.childAdded) { (snapshot) in
            guard let ssValue = snapshot.value as? [String:Any] else {return}
            guard let uid = ssValue["user"] as? String else {return}
            usersRef.child(uid).observeSingleEvent(of: .value) { (ss) in
                guard let dict = ss.value as? [String:AnyObject] else {return}
                let usr = User(uid: uid, details: dict)
                let comment = Comment(user: usr, dictionary: ssValue)
                self.comments.append(comment)
                self.tableView.reloadData()
            }
        }
    }
    
    private func uploadCommentNotifToServer() {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        if currUser == post.ownerUid {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let values : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currUser, "type" : commentIntValue, "postId" : post.postId]
        
        let notifRef = notificationsRef.child(post.ownerUid).childByAutoId()
        notifRef.updateChildValues(values)
    }
    
    private func handleHashtagTapped(for cell: CommentTableViewCell) {
        cell.commentLabel.handleHashtagTap { (hashtag) in
            self.pushTo(vc: HashtagViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
                vc.hashtag = hashtag
                return true
            }, completion: nil)
        }
    }
    
    private func handleMentionTapped(for cell: CommentTableViewCell) {
        cell.commentLabel.handleMentionTap { (username) in
            self.getMentionedUser(username: username)
        }
    }
}

extension CommentViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: comentCellIdentifier, for: indexPath) as! CommentTableViewCell
        cell.comment = comments[indexPath.row]
        handleHashtagTapped(for: cell)
        handleMentionTapped(for: cell)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension CommentViewController : InputAccessoryViewDelegate {
    func didSubmit(comment: String) {
        let text = comment
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let values : [String : Any] = ["commentText": text, "creationDate": creationDate, "user": uid]
        commentsRef.child(post.postId).childByAutoId().updateChildValues(values) { (error, ref) in
            self.uploadCommentNotifToServer()
            if text.contains("@") {
                self.uploadMentionedNotification(postId: self.post.postId, text: text, isCommentMention: true)
            }
            self.containerView.clearCommentTextView()
        }
    }
}
