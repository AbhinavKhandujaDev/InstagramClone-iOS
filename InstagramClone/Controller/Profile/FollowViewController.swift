//
//  FollowViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 05/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class FollowViewController: UIViewController {
    
    @IBOutlet weak var followTableView: UITableView!
    
    fileprivate let searchUserIdentifier = "searchUserCell"
    
    fileprivate var users = [User]()
    var uid : String?
    
    enum ViewingMode: Int {
        case following
        case followers
        case likes
        
        init(index: Int) {
            switch index {
            case 0:
                self = .following
            case 1:
                self = .followers
            case 2:
                self = .likes
            default:
                self = .following
            }
        }
    }
    
    private var currentKey : String?
    private let initialPostsCount: UInt = 20
    private let furtherPostsCount: UInt = 10
    
    var viewingMode : ViewingMode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        followTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: searchUserIdentifier)
        navigationItem.title = "Followers"
        
        switch viewingMode {
        case .followers?: navigationItem.title = "Followers"
        case .following?: navigationItem.title = "Following"
        case .likes?: navigationItem.title = "Likes"
        default: break
        }
        
        fetchUsers()
    }
    
    fileprivate func getDatabaseReference() -> DatabaseReference? {
        guard let mode = viewingMode else { return nil }
        switch mode {
        case .followers: return dbRef.child("user-follower")
        case .following: return dbRef.child("user-following")
        case .likes:     return postLikesRef
        }
    }
    
    fileprivate func fetchUsers() {
        guard let ref = getDatabaseReference() else { return }
        self.fetchUsers(databaseRef: ref.child(uid!), currentKey: currentKey, initialCount: initialPostsCount, furtherCount: furtherPostsCount, lastUserId: { (lastId) in
            self.currentKey = lastId.key
        }) { (user) in
            self.users.append(user)
            self.followTableView.reloadData()
        }
    }
}

extension FollowViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchUserIdentifier, for: indexPath) as! SearchTableViewCell
        cell.user = users[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (controller) in
            let vc = controller
            vc.user = self.users[indexPath.row]
            return true
        }, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > initialPostsCount - 1 && indexPath.item == self.users.count - 1{
            fetchUsers()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension FollowViewController: SearchTableCellDelegate {
    func handleFollowTapped(for cell: SearchTableViewCell) {
        if cell.followBtn.titleLabel?.text == "Follow" {
            cell.user?.follow(completion: { (done) in
                if done {
                    cell.followBtn.setTitle("Following", for: .normal)
                }
            })
        }else {
            cell.user?.unfollow(completion: { (done) in
                if done {
                    cell.followBtn.setTitle("Follow", for: .normal)
                }
            })
        }
    }
}
