//
//  HashtagViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 28/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class HashtagViewController: UICollectionViewController {

    private let reuseIdentifier = "hashtagCollCell"
    
    var posts = [Post]()
    var hashtag = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "#" + hashtag
        fetchPosts()
    }
    
    private func fetchPosts() {
        hashtagPostsRef.child(hashtag.lowercased()).observe(.childAdded) { (ss) in
            dbRef.fetchPost(postId: ss.key, completion: { (hashtagPost) in
                guard let post = hashtagPost else {return}
                self.posts.append(post)
                self.collectionView.reloadData()
            })
        }
    }

}

extension HashtagViewController : UICollectionViewDelegateFlowLayout {
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! HashtagCollectionViewCell
        cell.post = posts[indexPath.row]
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.pushTo(vc: HomeFeedViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.post = self.posts[indexPath.row]
            vc.viewSinglePost = true
            return true
        }, completion: nil)
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
