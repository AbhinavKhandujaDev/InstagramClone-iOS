//
//  SearchViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class SearchViewController: UIViewController {

    fileprivate let searchUserIdentifier = "searchUserCell"
    
    fileprivate var users = [User]()
    
    private let searchBar = UISearchBar()
    
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: searchUserIdentifier)
        fetchUsers()
    }
    
    fileprivate func fetchUsers() {
        dbRef.child("users").observe(.childAdded) { (snapshot) in
            guard let details = snapshot.value as? [String:AnyObject] else {return}
            let uid = snapshot.key
            
            let usr = User(uid: uid, details: details)
            self.users.append(usr)
            self.searchTableView.reloadData()
        }
    }
    
    private func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
        searchBar.placeholder = "Search"
    }

}

extension SearchViewController : UISearchBarDelegate {
    
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchUserIdentifier, for: indexPath) as! SearchTableViewCell
        cell.user = self.users[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (controller) in
            let vc = controller
            vc.user = self.users[indexPath.row]
            return true
        }, completion: nil)
    }
}

extension SearchViewController: SearchTableCellDelegate {
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
