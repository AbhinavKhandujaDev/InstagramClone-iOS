//
//  EditProfileViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 05/09/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class EditProfileViewController: UIViewController {

    @IBOutlet weak var profilePicImageView: CustomImageView!
    
    @IBOutlet weak var changeProfilePicBtn: UIButton!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var fullNameTxtField: UITextField!
    
    @IBOutlet weak var userNameTxtField: UITextField!
    
    var user: User?
    
    var profileVC : ProfileViewController!
    
    private var imageChanged : Bool = false
    
    private var updatedUsername : String?
    private var usernameChanged : Bool = false
    
    var bottomSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavBar()
        profilePicImageView.roundCorners()
        
        containerView.addSubview(bottomSeparatorView)
        bottomSeparatorView.anchor(top: nil, left: containerView.leftAnchor, bottom: containerView.bottomAnchor, right: containerView.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 0.5)
        
        setTextFields()
    }
    
    private func setTextFields() {
        fullNameTxtField.backgroundColor = .white
        userNameTxtField.backgroundColor = .white
        fullNameTxtField.addBottomBorder()
        userNameTxtField.addBottomBorder()
        
        guard let user = user else { return }
        guard let imageUrl = user.profileImageUrl else { return }
        fullNameTxtField.text = user.name
        userNameTxtField.text = user.username
        profilePicImageView.loadImage(with: imageUrl)
    }
    
    fileprivate func configureNavBar() {
        self.navigationController?.navigationBar.tintColor = .black
        self.navigationItem.title = "Edit Profile"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
    }
    
    private func updateProfileImage() {
        guard imageChanged == true else {return}
        guard let currentUid = Auth.auth().currentUser?.uid  else { return }
        guard let user = self.user else { return }
        
        Storage.storage().reference(forURL: user.profileImageUrl!).delete(completion: nil)
        
        let fileName = UUID().uuidString
        
        guard let newProfileImage = profilePicImageView.image else { return }
        
        guard let imageData = newProfileImage.jpegData(compressionQuality: 0.3) else { return }
        profileImageStorageRef.child(fileName).putData(imageData, metadata: nil) { (metaData, error) in
            guard error == nil else {return}
            guard let path = metaData?.path else {return}
            storageRef.child(path).downloadURL { (picUrl, error) in
                guard error == nil else {return}
                guard let url = picUrl?.absoluteString else {return}
                
                usersRef.child(currentUid).child("profileImageUrl").setValue(url, withCompletionBlock: { (error, ref) in
                    self.profileVC.fetchCurrentUserData()
                    self.dismiss(animated: true, completion: nil)
                })
            }
        }
    }
    
    private func updateUsername() {
        guard let currentUid = Auth.auth().currentUser?.uid  else { return }
        guard let updatedUsername = self.updatedUsername else { return }
        guard  usernameChanged == true else { return }
        
        usersRef.child(currentUid).child("username").setValue(updatedUsername) { (error, ref) in
            self.profileVC.fetchCurrentUserData()
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc fileprivate func cancelTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func doneTapped() {
        view.endEditing(true)
        
        if usernameChanged {
            updateUsername()
        }
        
        if imageChanged {
            updateProfileImage()
        }
    }

    @IBAction func changeProfilePicTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true, completion: nil)
    }
}

extension EditProfileViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profilePicImageView.image = selectedImage
            imageChanged = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

extension EditProfileViewController : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let user = self.user else { return }
        
        let trimmedString = textField.text?.replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)
        
        guard user.username != trimmedString else {
            print("username not changed")
            return
        }
        
        guard trimmedString != "" else {
            print("please enter a valid username")
            return
        }
        
        self.updatedUsername = trimmedString?.lowercased()
        self.usernameChanged = true
    }
}
