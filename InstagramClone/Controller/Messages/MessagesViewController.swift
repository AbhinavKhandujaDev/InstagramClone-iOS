//
//  MessagesViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 25/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UITableViewController {
    
    private let messagesCellIdentifier = "messageTableCell"
    
    private var messages = [Message]()
    
    private var messagesDict = [String:Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        fetchMessages()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Messages"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.handleNewMessage))
    }
    
    deinit {
        print("MessagesViewController deinit")
    }
    
    @objc private func handleNewMessage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "NewMessageTableViewController") as! NewMessageTableViewController
        controller.messagesController = self
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
    
    private func fetchMessages() {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        self.messages.removeAll()
        self.messagesDict.removeAll()
        self.tableView.reloadData()
        userMessagesRef.child(currUser).observe(.childAdded) {[weak self] (ss) in
            let uid = ss.key
            userMessagesRef.child(currUser).child(uid).observe(.childAdded, with: { (childSS) in
                let msgId = childSS.key
                self?.fetchMessage(messageId: msgId)
            })
        }
    }
    
    private func fetchMessage(messageId: String) {
        messagesRef.child(messageId).observeSingleEvent(of: .value) {[weak self] (ss) in
            guard let dict = ss.value as? [String:Any] else {return}
            let message = Message(dictionary: dict)
            
            let partnerId = message.getChatPartnerId()
            self?.messagesDict[partnerId] = message
            
            guard let values = self?.messagesDict.values else {return}
            self?.messages = Array(values)
            
            self?.tableView.reloadData()
        }
    }
    
    func showChatController(forUser user: User) {
        self.pushTo(vc: ChatViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.user = user
            return true
        }, completion: nil)
    }
    
}

extension MessagesViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: messagesCellIdentifier, for: indexPath) as! MessagesTableViewCell
        cell.identifier = messagesCellIdentifier
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let partnerId = messages[indexPath.row].getChatPartnerId()
        dbRef.fetchUser(uid: partnerId) {[weak self] (user) in
            self?.showChatController(forUser: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
