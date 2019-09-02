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
    fileprivate let searchCollIdentifier = "searchCollCell"
    
    fileprivate var users = [User]()
    private var posts = [Post]()
    
    private var filteredUsers = [User]()
    private var isSearching = false
    private var collectionViewEnabled = false
    
    private var postCurrentKey : String?
    private let initialPostsCount : UInt = 21
    private let furtherPostsCount : UInt = 10
    
    private var userCurrentKey : String?
    private let initialUsersCount : UInt = 21
    private let furtherUsersCount : UInt = 10
    
    private var collectionView : UICollectionView!
    
    private let searchBar = UISearchBar()
    
    @IBOutlet weak var searchTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSearchBar()
        
        searchTableView.register(UINib(nibName: "SearchTableViewCell", bundle: nil), forCellReuseIdentifier: searchUserIdentifier)
        
        fetchPosts()
        
        configureCollectionView()
    }
    
    private func configureCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: searchTableView.frame.height)

        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.contentInset.bottom = (tabBarController?.tabBar.frame.height)! * 2.5
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = .white
        searchTableView.addSubview(collectionView)
        
        collectionView.register(UINib(nibName: "SearchCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: searchCollIdentifier)
    }
    
    private func configureSearchBar() {
        searchBar.sizeToFit()
        searchBar.delegate = self
        navigationItem.titleView = searchBar
        searchBar.barTintColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
        searchBar.tintColor = .black
        searchBar.placeholder = "Search"
        searchBar.showsCancelButton = true
    }
    
    fileprivate func fetchUsers() {
        self.fetchUsers(databaseRef: usersRef, currentKey: userCurrentKey, initialCount: initialUsersCount, furtherCount: furtherUsersCount, lastUserId: { (lastId) in
            self.userCurrentKey = lastId.key
        }) { (user) in
            self.users.append(user)
            self.searchTableView.reloadData()
        }
    }
    
    private func fetchPosts() {
        self.fetchPosts(databaseRef: postsRef, currentKey: postCurrentKey, initialCount: initialPostsCount, furtherCount: furtherPostsCount, lastPostId: { (lastId) in
            self.postCurrentKey = lastId.key
        }) { (post) in
            self.posts.append(post)
            self.posts.sort(by: {$0.createdAt > $1.createdAt})
            self.collectionView.reloadData()
        }
    }
    
}

extension SearchViewController : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        fetchUsers()
        collectionView.isHidden = true
        collectionViewEnabled = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchedText = searchText.lowercased()
        if searchText.isEmpty || searchText == " " {
            isSearching = false
            searchTableView.reloadData()
        }else {
            isSearching = true
            filteredUsers = users.filter { (user) -> Bool in
                return (user.username?.contains(searchedText))!
            }
            searchTableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchBar.showsCancelButton = false
        searchBar.text = nil
        isSearching = false
        searchTableView.reloadData()
        collectionViewEnabled = true
        collectionView.isHidden = false
    }

}

extension SearchViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: searchCollIdentifier, for: indexPath) as! SearchCollectionViewCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pushTo(vc: HomeFeedViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.post = self.posts[indexPath.row]
            vc.viewSinglePost = true
            return true
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if posts.count > initialPostsCount - 1 && indexPath.item == posts.count - 1 {
            fetchPosts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 2)/3
        return CGSize(width: width, height: width)
    }
}

extension SearchViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearching {
            return filteredUsers.count
        }
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: searchUserIdentifier, for: indexPath) as! SearchTableViewCell
        if isSearching {
            cell.user = self.filteredUsers[indexPath.row]
        }else {
            cell.user = self.users[indexPath.row]
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if users.count > initialUsersCount - 1 && indexPath.row == users.count - 1 {
            fetchUsers()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (controller) in
            let vc = controller
            if self.isSearching {
                vc.user = self.filteredUsers[indexPath.row]
            }else {
                vc.user = self.users[indexPath.row]
            }
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
