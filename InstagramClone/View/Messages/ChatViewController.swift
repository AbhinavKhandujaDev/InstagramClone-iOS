//
//  ChatViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 26/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UITableViewController {
    
    private var chatCellIdentifier = "chatTableCell"
    var user : User?
    var messages = [Message]()
    
    lazy var containerView: CommentInputAccessoryView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        let cView = CommentInputAccessoryView(frame: frame)
        cView.delegate = self
        cView.backgroundColor = UIColor.white
        return cView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        observeMessage()
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
    
    private func configureNavBar() {
        if let user = user {
            navigationItem.title = user.username
        }
        let infoButton = UIButton(type: .infoDark)
        infoButton.tintColor = .black
        infoButton.addTarget(self, action: #selector(handleInfoTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: infoButton)
    }
    
    @objc private func handleInfoTapped() {
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.user = self.user
            return true
        }, completion: nil)
    }
    
    private func observeMessage() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let chatPartnerId = user?.uid else { return }
        
        userMessagesRef.child(currentUid).child(chatPartnerId).observe(.childAdded) { (ss) in
            let messageId = ss.key
            self.fetchMessage(messageId: messageId)
        }
    }
    
    private func fetchMessage(messageId: String) {
        messagesRef.child(messageId).observeSingleEvent(of: .value) { (ss) in
            guard let dict = ss.value as? [String:Any] else {return}
            let message = Message(dictionary: dict)
            self.messages.append(message)
            self.tableView.reloadData()
        }
    }
    
}

extension ChatViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: chatCellIdentifier, for: indexPath) as! ChatTableViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension ChatViewController : InputAccessoryViewDelegate {
    func didSubmit(comment: String) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        let messageValues : [String:Any] = ["creationDate" : creationDate, "fromId": currentUid, "toId": userId, "messageText": comment]
        
        let msgRef = messagesRef.childByAutoId()
        guard let key = msgRef.key else { return }
        
        msgRef.updateChildValues(messageValues) { (error, ref) in
            userMessagesRef.child(currentUid).child(userId).updateChildValues([key : 1])
            userMessagesRef.child(userId).child(currentUid).updateChildValues([key : 1])
        }
        
        self.containerView.clearCommentTextView()
    }
}
