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
    
//    fileprivate let followCellIdentifier = "followCell"
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
        print(viewingMode.rawValue)
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
        ref.child(uid!).observeSingleEvent(of: .value) { (snapshot) in
            guard let allIds = snapshot.children.allObjects as? [DataSnapshot] else {return}
            allIds.forEach({ (usrid) in
                let userId = usrid.key
                usersRef.child(userId).observeSingleEvent(of: .value, with: { (objSnapshot) in
                    guard let details = objSnapshot.value as? [String:AnyObject] else {return}
                    let usr = User(uid: objSnapshot.key, details: details)
                    
                    self.users.append(usr)
                    self.followTableView.reloadData()
                })
            })
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
