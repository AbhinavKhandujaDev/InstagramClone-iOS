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
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var image : UIImage?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    fileprivate func updateUserFeeds(with postId: String) {
        guard let currentUsr = loggedInUid else { return }
        let values = [postId:1]
        
        //update follower feed
        dbRef.child("user-follower").child(currentUsr).observe(.childAdded) { (ss) in
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
    
    @IBAction func submitTapped(_ sender: UIButton) {
        guard let uid = loggedInUid else{return}
        guard let uploadData = image?.jpegData(compressionQuality: 0.1) else {return}
        let creationDate = Int(Date().timeIntervalSince1970)
        let filename = UUID().uuidString
        storageRef.child("post_images").child(filename).putData(uploadData, metadata: nil) { (metadata, error) in
            if error != nil {
                print("error in uploading ",error?.localizedDescription as Any)
                return
            }
            
            guard let path = metadata?.path else{return}
            storageRef.child(path).downloadURL(completion: { (picUrl, urlError) in
                if urlError != nil {
                    print("error in getting image url: ",urlError as Any)
                    return
                }
                guard let url = picUrl?.absoluteString else{return}
                let values = ["caption": self.captionTextView.text!, "createdAt": creationDate, "likes" : 0, "imageUrl": url, "uid" : uid] as [String : Any]
                let postId = dbRef.child("posts").childByAutoId()
                postId.updateChildValues(values, withCompletionBlock: { (error, ref) in
                    dbRef.child("user-posts").child(loggedInUid!).updateChildValues([postId.key! : 1])
                    self.updateUserFeeds(with: postId.key!)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                })
            })
        }
    }
}
