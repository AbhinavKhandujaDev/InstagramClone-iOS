//
//  NewMessageTableViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 26/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class NewMessageTableViewController: UITableViewController {

    private let newMsgCellIdentifier = "newMsgTableCell"
    
    var messagesController : MessagesViewController?
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        fetchUsers()
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.handleCancel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    @objc private func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func fetchUsers() {
        usersRef.observe(.childAdded) { (ss) in
            let uid = ss.key
            if uid != loggedInUid! {
                dbRef.fetchUser(uid: uid, completion: { (user) in
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }
    }
    
}

extension NewMessageTableViewController {
    
    // MARK:- TableView Functions
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: newMsgCellIdentifier, for: indexPath) as! NewMessageTableViewCell
        cell.user = users[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}
