//
//  HomeFeedViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase
import ActiveLabel

class HomeFeedViewController: UICollectionViewController {
    
    fileprivate let feedCellIdentifier = "feedCell"
    
    fileprivate var feeds = [Post]()
    
    private var currentKey : String?
    private let initialPostsCount: UInt = 5
    private let furtherPostsCount: UInt = 6
    
    var profileVC : ProfileViewController?
    
    var viewSinglePost : Bool = false
    var post : Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "HomeFeedCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: feedCellIdentifier)
        fetchPosts()

        let refreshCtrl = UIRefreshControl()
        refreshCtrl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshCtrl
        
        self.navigationItem.title = !viewSinglePost ? "Home" : "Post"
    }
    
    @objc fileprivate func handleRefresh() {
        feeds.removeAll(keepingCapacity: true)
        currentKey = nil
        fetchPosts()
        collectionView.reloadData()
    }
    
    fileprivate func fetchPosts() {
        if viewSinglePost {
            guard let post = post else {return}
            feeds.append(post)
            return
        }
        guard let currentUser = Auth.auth().currentUser?.uid else { return }

        self.fetchPosts(databaseRef: userFeedRef.child(currentUser), currentKey: currentKey, initialCount: initialPostsCount, furtherCount: furtherPostsCount, lastPostId: { (first) in
            self.collectionView.refreshControl?.endRefreshing()
            self.currentKey = first.key
        }) { (post) in
            self.feeds.append(post)
            self.feeds.sort(by: {$0.createdAt > $1.createdAt})
            self.collectionView.reloadData()
        }
    }

    @IBAction func showMessagesTapped(_ sender: UIBarButtonItem) {
        self.pushTo(vc: MessagesViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            return true
        }, completion: nil)
    }
}

extension HomeFeedViewController : UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feeds.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: feedCellIdentifier, for: indexPath) as! HomeFeedCollectionViewCell
        let feed = feeds[indexPath.row]
        cell.post = feed
        cell.delegate = self
        handleMentionTapped(for: cell)
        handleHashtagTapped(for: cell)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if feeds.count > initialPostsCount - 1 && indexPath.item == self.feeds.count - 1{
            fetchPosts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width
        let height = width + 8 + 40 + 8 + 50 + 60
        return CGSize(width: width, height: height)
    }
    
}

extension HomeFeedViewController : FeedCellDelegate {
    func handleShowMessages(for feedCell: HomeFeedCollectionViewCell) {
        self.pushTo(vc: ChatViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.user = feedCell.post?.user
            return true
        }, completion: nil)
    }
    
    func handleUsernameTapped(for feedCell: HomeFeedCollectionViewCell) {
        self.pushTo(vc: ProfileViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            guard let uid = feedCell.post?.ownerUid else {return false}
            usersRef.child(uid).observeSingleEvent(of: .value, with: { (ss) in
                guard let ss = ss.value as? [String:AnyObject] else {return}
                let user = User(uid: (feedCell.post?.ownerUid)!, details: ss)
                vc.user = user
            })
            return true
        }, completion: nil)
    }
    
    func handleOptionsTapped(for feedCell: HomeFeedCollectionViewCell) {
        guard let post = feedCell.post else { return }
        let alertController = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { (action) in
            post.deletePost()
            if !self.viewSinglePost {
                self.handleRefresh()
            }else {
                if let userProfileVC = self.profileVC {
                    self.navigationController?.popViewController(animated: true)
                    userProfileVC.handleRefresh()
                }
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "Edit Post", style: .default, handler: { (action) in
            self.pushTo(vc: PostViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
                vc.postToEdit = post
                return true
            }, completion: nil)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func handleLikeTapped(for feedCell: HomeFeedCollectionViewCell) {
        guard let post = feedCell.post else { return }
        if post.didLike {
            post.adjustLikes(addLike: false) { (likesCount) in
                feedCell.likeBtn.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
                feedCell.likesLabel.text = String(likesCount) + " " + "likes"
            }
        }else {
            post.adjustLikes(addLike: true) { (likesCount) in
                feedCell.likeBtn.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
                feedCell.likesLabel.text = String(likesCount) + " " + "likes"
            }
        }
    }
    
    func handleCommentTapped(for feedCell: HomeFeedCollectionViewCell) {
        self.pushTo(vc: CommentViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            guard let post = feedCell.post else {return false}
            vc.post = post
            return true
        }, completion: nil)
    }
    
    func handleConfigureLikeButton(for feedCell: HomeFeedCollectionViewCell) {
        guard let post = feedCell.post else { return }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        userLikesRef.child(userId).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(post.postId) {
                post.didLike = true
                feedCell.likeBtn.setImage(#imageLiteral(resourceName: "like_selected"), for: .normal)
            }else {
                post.didLike = false
                feedCell.likeBtn.setImage(#imageLiteral(resourceName: "like_unselected"), for: .normal)
            }
        }
    }
    
    func handleShowLikes(for feedCell: HomeFeedCollectionViewCell) {
        self.pushTo(vc: FollowViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.viewingMode = FollowViewController.ViewingMode(index: 2)
            vc.uid = feedCell.post?.postId
            return true
        }, completion: nil)
    }
    
    private func handleHashtagTapped(for feedCell: HomeFeedCollectionViewCell) {
        feedCell.captionLabel.handleHashtagTap { (hashtag) in
            
            self.pushTo(vc: HashtagViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
                vc.hashtag = hashtag
                return true
            }, completion: nil)
        }
    }
    
    private func handleMentionTapped(for feedCell: HomeFeedCollectionViewCell) {
        feedCell.captionLabel.handleMentionTap { (username) in
            self.getMentionedUser(username: username)
        }
    }
}
