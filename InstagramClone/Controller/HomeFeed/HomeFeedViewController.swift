//
//  HomeFeedViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class HomeFeedViewController: UIViewController {

    @IBOutlet weak var feedCollView: UICollectionView!
    
    fileprivate let feedCellIdentifier = "feedCell"
    
    fileprivate var feeds = [Post]()
    
    var viewSinglePost : Bool = false
    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        feedCollView.register(UINib(nibName: "HomeFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: feedCellIdentifier)
        fetchPosts()
        
        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        feedCollView.refreshControl = refreshCtrl
    }
    
    fileprivate func configureNavBar() {
        self.navigationItem.title = "Home Feed"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "send2"), style: .plain, target: self, action: nil)
        
        if !viewSinglePost {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        }
    }
    
    @objc fileprivate func handleRefresh() {
        feeds.removeAll(keepingCapacity: true)
        fetchPosts()
        feedCollView.reloadData()
    }
    
    fileprivate func fetchPosts() {
        if viewSinglePost {
            feeds.append(post!)
            return
        }
        guard let currentUser = loggedInUid else { return }
        userFeedRef.child(currentUser).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            dbRef.fetchPost(postId: postId, completion: { (post) in
                guard let post = post else{return}
                self.feeds.append(post)
                self.feeds.sort(by: {$0.createdAt > $1.createdAt})
                self.feedCollView.refreshControl?.endRefreshing()
                self.feedCollView.reloadData()
            })
        }
    }
    
//    fileprivate func updateUserFeeds() {
//        guard let currentUser = loggedInUid else { return }
//        dbRef.child("user-following").child(currentUser).observe(.childAdded) { (snapshot) in
//            let followingUser = snapshot.key
//            dbRef.child("user-posts").child(followingUser).observeSingleEvent(of: .value, with: { (ss) in
//                if let ss = ss.value {
//                    self.fetchPosts()
//                }
//            })
//        }
//    }
    
    @objc fileprivate func logout() {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { (_) in
            do{
                try Auth.auth().signOut()
                self.tabBarController?.presentVC(withIdentifier: "RootNavViewController")
            }catch{
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeFeedViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellIdentifier, for: indexPath) as! HomeFeedCollectionViewCell
        cell.post = feeds[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 8 + 40 + 8 + 50 + 60
        return CGSize(width: width, height: height)
    }
    
}

extension HomeFeedViewController : FeedCellDelegate {
    func handleUsernameTapped(for feedCell: HomeFeedCollectionViewCell) {
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            guard let uid = feedCell.post?.ownerUid else {return false}
            dbRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (ss) in
                guard let ss = ss.value as? [String:AnyObject] else {return}
                let user = User(uid: (feedCell.post?.ownerUid)!, details: ss)
                vc.user = user
            })
            return true
        }, completion: nil)
    }
    
    func handleOptionsTapped(for feedCell: HomeFeedCollectionViewCell) {
        
    }
    
    func handleLikeTapped(for feedCell: HomeFeedCollectionViewCell) {
        
    }
    
    func handleCommentTapped(for feedCell: HomeFeedCollectionViewCell) {
        
    }
}
