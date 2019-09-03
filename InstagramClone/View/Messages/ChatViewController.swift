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
//    private var chatCellIdentifier = "chatCollCell"
    private var chatCellIdentifier = "chatTableCell"
    var user : User?
    var messages = [Message]()
    
    lazy var containerView: UIView = {
        let cView = UIView()
        cView.backgroundColor = UIColor.white
        cView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        cView.addSubview(sendBtn)
        sendBtn.anchor(top: nil, left: nil, bottom: nil, right: cView.rightAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 50, height: 50)
        sendBtn.centerYAnchor.constraint(equalTo: cView.centerYAnchor).isActive = true
        
        cView.addSubview(messageTextField)
        messageTextField.anchor(top: cView.topAnchor, left: cView.leftAnchor, bottom: cView.bottomAnchor, right: sendBtn.leftAnchor, paddingTop: 0, paddingLeft: 8, paddingBottom: 0, paddingRight: 8, width: 0, height: 0)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        cView.addSubview(separatorView)
        separatorView.anchor(top: cView.topAnchor, left: cView.leftAnchor, bottom: nil, right: cView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        return cView
    }()
    
    let messageTextField : UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter message..."
        tf.font = UIFont.systemFont(ofSize: 14)
        return tf
    }()
    
    let sendBtn : UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Send", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        btn.addTarget(self, action: #selector(handleSendTapped), for: .touchUpInside)
        return btn
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
    
    @objc private func handleSendTapped() {
        uploadMessageToServer()
        messageTextField.text = nil
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
    
    private func uploadMessageToServer() {
        guard let messageText = messageTextField.text else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let userId = user?.uid else { return }
        let creationDate = Int(Date().timeIntervalSince1970)
        let messageValues : [String:Any] = ["creationDate" : creationDate, "fromId": currentUid, "toId": userId, "messageText": messageText]
        
        let msgRef = messagesRef.childByAutoId()
        guard let key = msgRef.key else { return }
        
        msgRef.updateChildValues(messageValues) { (error, ref) in
            userMessagesRef.child(currentUid).child(userId).updateChildValues([key : 1])
            userMessagesRef.child(userId).child(currentUid).updateChildValues([key : 1])
        }
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
//            self.collectionView.reloadData()
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

//extension ChatViewController: UICollectionViewDelegateFlowLayout {
//    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return messages.count
//    }
//
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chatCellIdentifier, for: indexPath) as! ChatCollectionViewCell
//        cell.backgroundColor = .red
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let width : CGFloat = view.frame.width/2
//        let height : CGFloat = 50
//        return CGSize(width: width, height: height)
//    }
//}
