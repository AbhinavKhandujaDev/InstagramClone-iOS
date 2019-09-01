//
//  NotificationViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class NotificationViewController: UITableViewController {
    
    private let cellIdentifier = "notifTableCell"
    
    private var notifs : [Notification] = []
    
    private var timer : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Notifications"
        fetchNotifs()
    }
    
    private func handleReloadTable() { //solves problem with hiding/unhiding postImageView/follow button
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nil, repeats: false)
    }
    
    @objc private func handleSortNotifications() {
        self.notifs.sort(by: {$0.creationDate > $1.creationDate})
        self.tableView.reloadData()
    }
    
    private func fetchNotifs() {
        guard let currUser = loggedInUid else { return }
        notificationsRef.child(currUser).observe(.childAdded) { (ss) in
            let id = ss.key
            guard let dict = ss.value as? [String:Any] else {return}
            guard let uid = dict["uid"] as? String else{return}
            
            dbRef.fetchUser(uid: uid, completion: { (user) in
                var notif : Notification?
                if let postId = dict["postId"] as? String {
                    dbRef.fetchPost(postId: postId, completion: { (post) in
                        notif = Notification(user: user, post: post, dict: dict)
                        self.notifs.append(notif!)
                        self.handleReloadTable()
                    })
                }else {
                    notif = Notification(user: user, dict: dict)
                    self.notifs.append(notif!)
                    self.handleReloadTable()
                }
            })
            notificationsRef.child(currUser).child(id).child("checked").setValue(1)
        }
    }
}

extension NotificationViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationsTableViewCell
        cell.notification = notifs[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let notif = notifs[indexPath.row]
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.user = notif.user!
            return true
        }, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension NotificationViewController: NotificationCellDelegate {
    func handleFollowTapped(for notifCell: NotificationsTableViewCell) {
        if notifCell.followButton.title(for: .normal) == "Follow" {
            notifCell.notification?.user.follow(completion: { (done) in
                if done {
                    notifCell.followButton.setTitle("Following", for: .normal)
                }
            })
        }else {
            notifCell.notification?.user.unfollow(completion: { (done) in
                if done {
                    notifCell.followButton.setTitle("Follow", for: .normal)
                }
            })
        }
    }
    
    func handlePostTapped(for notifCell: NotificationsTableViewCell) {
        guard let post = notifCell.notification?.post else { return }
        if post.postId == nil {return}
        self.pushTo(vc: HomeFeedViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.post = notifCell.notification?.post
            vc.viewSinglePost = true
            return true
        }, completion: nil)
    }
}
