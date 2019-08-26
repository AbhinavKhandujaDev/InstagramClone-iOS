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
    
    lazy var containerView: UIView = {
        let cView = UIView()
        cView.backgroundColor = UIColor.white
        cView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        cView.addSubview(postButton)
        postButton.anchor(top: nil, left: nil, bottom: nil, right: cView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
        postButton.centerYAnchor.constraint(equalTo: cView.centerYAnchor).isActive = true
        
        cView.addSubview(commentTextField)
        commentTextField.anchor(top: cView.topAnchor, left: cView.leftAnchor, bottom: cView.bottomAnchor, right: postButton.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        cView.addSubview(separatorView)
        separatorView.anchor(top: cView.topAnchor, left: cView.leftAnchor, bottom: nil, right: cView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return cView
    }()
    
    let commentTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter comment..."
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let postButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Post", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleUploadComment), for: .touchUpInside)
        return btn
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
    
    @objc private func handleUploadComment() {
        if !commentTextField.hasText {return}
        guard let text = commentTextField.text else {return}
        guard let uid = loggedInUid else {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let values : [String : Any] = ["commentText": text, "creationDate": creationDate, "user": uid]
        commentsRef.child(post.postId).childByAutoId().updateChildValues(values) { (error, ref) in
            self.uploadCommentNotifToServer()
            self.commentTextField.text = nil
        }
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
        guard let currUser = loggedInUid else { return }
        if currUser == post.ownerUid {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let values : [String:Any] = ["checked" : 0, "creationDate" : creationDate, "uid" : currUser, "type" : commentIntValue, "postId" : post.postId]
        
        let notifRef = notificationsRef.child(post.ownerUid).childByAutoId()
        notifRef.updateChildValues(values)
    }
}

extension CommentViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: comentCellIdentifier, for: indexPath) as! CommentTableViewCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
