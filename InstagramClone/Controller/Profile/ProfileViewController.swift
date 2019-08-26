//
//  ProfileViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {

    private let cellIdentifier = "profileCollCell"
    private let headerIdentifier = "profileHeaderCell"
    
    @IBOutlet weak var profileCollView: UICollectionView!
    
    var user : User?
    var posts = [Post]()
    
    fileprivate var horizontalSpace : CGFloat = 3
    fileprivate var verticalSpace : CGFloat = 3
    fileprivate var padding: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileCollView.register(UINib(nibName: "ProfileHeaderCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        if let layout = profileCollView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
        
        if user?.uid != nil {
            fetchPost(uid: (user?.uid)!)
        }else {
            fetchCurrentUserData()
            fetchPost()
        }
    }
    
    fileprivate func fetchPost(uid: String = loggedInUid!) {
        dbRef.child("user-posts").child(uid).observe(.childAdded) { (snapshot) in
            let postId = snapshot.key
            dbRef.child("posts").child(postId).observeSingleEvent(of: .value, with: { (ss) in
                guard let dict = ss.value as? [String:Any] else {return}
                let post = Post(postId: ss.key, dict: dict)
                self.posts.append(post)
                self.posts.sort(by: {$0.createdAt > $1.createdAt})
                self.profileCollView.reloadData()
            })
        }
    }

    fileprivate func fetchCurrentUserData() {
        let date = Date()
        let currentUid = loggedInUid
        usersRef.child(currentUid!).observeSingleEvent(of: .value) { (snapshot) in
            let uid = snapshot.key
            guard let details = snapshot.value as? [String:AnyObject] else {return}
            self.user = User(uid: uid, details: details)
            self.navigationItem.title = self.user?.username
            self.profileCollView.reloadData()
            print("time taken to fetch: ",Date().timeIntervalSince(date), " seconds")
        }
    }
    
    @IBAction func logoutTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure?", message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: {[weak self] (_) in
            do{
                try Auth.auth().signOut()
                self?.tabBarController?.presentVC(withIdentifier: "RootNavViewController")
                self?.user = nil
                imageCache.removeAll()
                self?.tabBarController?.selectedIndex = 0
            }catch{
                
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! UserPostsCollectionViewCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeaderCell
        header.delegate = self
        header.user = self.user
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pushTo(vc: HomeFeedViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.post = self.posts[indexPath.row]
            vc.viewSinglePost = true
            return true
        }, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowWidth = (view.frame.width - (horizontalSpace*3)) - 2*padding
        let width = rowWidth/4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return horizontalSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return verticalSpace
    }
}

extension ProfileViewController: ProfileHeaderDelegate {
    
    func handleFollowersTapped(for header: ProfileHeaderCell) {
        self.pushTo(vc: FollowViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.viewingMode = FollowViewController.ViewingMode(index: 1)
            vc.uid = self.user?.uid
            return true
        }, completion: nil)
    }
    
    func handleFollowingTapped(for header: ProfileHeaderCell) {
        self.pushTo(vc: FollowViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.viewingMode = FollowViewController.ViewingMode(index: 0)
            vc.uid = self.user?.uid
            return true
        }, completion: nil)
    }
    
    func setUserStats(for header: ProfileHeaderCell) {
        let textAttrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14)]
        let appendTextAttrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        
        var numbOfFollowers: Int = 0
        var numbOfFollowings : Int = 0
        
        dbRef.child("user-follower").child((header.user?.uid)!).observe(.value) { (snapshot) in
            if let ss = snapshot.value as? [String:AnyObject] {
                numbOfFollowers = ss.count
            }else {
                numbOfFollowers = 0
            }
            header.followersLabel.setAttributedString(text: "\(String(describing: numbOfFollowers))\n", textAttributes: textAttrs, appendText: "followers", appendTextAttributes: appendTextAttrs)
        }
        
        dbRef.child("user-following").child((header.user?.uid)!).observe(.value) { (snapshot) in
            if let ss = snapshot.value as? [String:AnyObject] {
                numbOfFollowings = ss.count
            }else {
                numbOfFollowings = 0
            }
            header.followingLabel.setAttributedString(text: "\(String(describing: numbOfFollowings))\n", textAttributes: textAttrs, appendText: "following", appendTextAttributes: appendTextAttrs)
        }
    }
    
    func handleEditFollowTapped(for header: ProfileHeaderCell) {
        if header.editProfileBtn.titleLabel?.text == "Follow" {
            header.user?.follow(completion: { (done) in
                if !done {return}
                header.editProfileBtn.setTitle("Following", for: .normal)
            })
        }else if header.editProfileBtn.titleLabel?.text == "Following" {
            header.user?.unfollow(completion: { (done) in
                if !done{return}
                header.editProfileBtn.setTitle("Follow", for: .normal)
            })
        }
    }
}
