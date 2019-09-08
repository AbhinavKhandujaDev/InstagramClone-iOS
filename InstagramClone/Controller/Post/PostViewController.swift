//
//  PostViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class PostViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var photoImageView: CustomImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var image : UIImage?
    
    var postToEdit : Post?
    
    fileprivate var disableSubmitBtn : Bool = true {
        didSet {
            submitBtn.isEnabled = disableSubmitBtn ? false : true
            submitBtn.backgroundColor = disableSubmitBtn ? UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1) : UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let image = self.image {
            self.photoImageView.image = image
        }
        submitBtn.layer.cornerRadius = 5
        disableSubmitBtn = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Update the post
        guard let post = postToEdit else { return }
        
        self.photoImageView.loadImage(with: post.imageUrl)
        self.captionTextView.text = post.caption
        self.navigationItem.title = "Edit Post"
        self.submitBtn.setTitle("Update post", for: .normal)
    }
    
    fileprivate func updateUserFeeds(with postId: String) {
        guard let currentUsr = Auth.auth().currentUser?.uid else { return }
        let values = [postId:1]
        
        //update follower feed
        userFollowerRef.child(currentUsr).observe(.childAdded) { (ss) in
            let followerUid = ss.key
            userFeedRef.child(followerUid).updateChildValues(values)
        }
        
        //update own feed
        userFeedRef.child(currentUsr).updateChildValues(values)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.hasText {
            disableSubmitBtn = false
        }else {
            disableSubmitBtn = true
        }
    }
    
    private func uploadHashtagToServer(withId postId: String) {
        guard let caption = captionTextView.text else { return }
        let wordsArray = caption.components(separatedBy: .whitespacesAndNewlines)
        
        wordsArray.forEach { (word) in
            var mutableWord = word
            if word.hasPrefix("#") {
                mutableWord = mutableWord.trimmingCharacters(in: .punctuationCharacters).trimmingCharacters(in: .symbols)
                let hashtagValues = [postId:1]
                hashtagPostsRef.child(mutableWord.lowercased()).updateChildValues(hashtagValues)
            }
        }
    }
    
    private func handleUploadPost() {
        guard let uid = Auth.auth().currentUser?.uid else{return}
        guard let uploadData = image?.jpegData(compressionQuality: 0.1) else {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let filename = UUID().uuidString
        storageRef.child("post_images").child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("error in uploading ",error?.localizedDescription as Any)
                return
            }
            
            guard let path = metadata?.path else{return}
            storageRef.child(path).downloadURL(completion: {[weak self] (picUrl, urlError) in
                if urlError != nil {
                    print("error in getting image url: ",urlError as Any)
                    return
                }
                guard let url = picUrl?.absoluteString else{return}
                
                guard let captionText = self?.captionTextView.text else {return}
                
                let values = ["caption": captionText, "createdAt": creationDate, "likes" : 0, "imageUrl": url, "uid" : uid] as [String : Any]
                
                let postId = postsRef.childByAutoId()
                
                postId.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    self?.uploadHashtagToServer(withId: postId.key!)
                    
                    if captionText.contains("@") {
                        self?.uploadMentionedNotification(postId: postId.key!, text: captionText, isCommentMention: false)
                    }
                    
                    userPostsRef.child(uid).updateChildValues([postId.key! : 1])
                    self?.updateUserFeeds(with: postId.key!)
                    self?.navigationController?.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
    
    private func handleUpdatePost() {
        guard let text = captionTextView.text else { return }
        guard let post = postToEdit else { return }
        uploadHashtagToServer(withId: post.postId)
        postsRef.child(post.postId).child("caption").setValue(text) {[weak self] (error, ref) in
            if error == nil {
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func submitTapped(_ sender: UIButton) {
        if postToEdit == nil {
            handleUploadPost()
        }else {
            handleUpdatePost()
        }
    }
}
