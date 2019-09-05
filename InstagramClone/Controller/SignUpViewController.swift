//
//  SignUpViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    @IBOutlet weak var profileImgBtn: UIButton!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet var txtFields: [UITextField]!
    
    fileprivate var imageSelected = false
    
    fileprivate var disableSignUpBtn : Bool = true {
        didSet {
            signUpBtn.backgroundColor = disableSignUpBtn ? UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1) : UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            signUpBtn.isEnabled = disableSignUpBtn ? false : true
        }
    }
    
    fileprivate let alreadyHaveAccountBtn : UIButton = {
        let btn = UIButton(type: .system)
        let attrString = NSMutableAttributedString(string: "Already have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attrString.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        btn.setAttributedTitle(attrString, for: .normal)
        btn.addTarget(self, action: #selector(alreadyHaveAccountBtnAction), for: .touchUpInside)
        
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        signUpBtn.layer.cornerRadius = 5
        txtFields.forEach({$0.setDefaultTextField(placeHolder: $0.placeholder ?? "")})
        
        txtFields.forEach { (field) in
            field.setDefaultTextField(placeHolder: field.placeholder ?? "")
            field.delegate = self
            field.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        }
        
        view.addSubview(alreadyHaveAccountBtn)
        alreadyHaveAccountBtn.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 15, paddingRight: 0, width: 0, height: 50)
        
        disableSignUpBtn = true
        
        profileImgBtn.layer.cornerRadius = profileImgBtn.frame.height/2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @objc fileprivate func formValidation() {
        guard txtFields[0].hasText, txtFields[1].hasText, txtFields[2].hasText, txtFields[3].hasText, imageSelected else {return}
        
        if txtFields[0].text!.isValidEmail {
            disableSignUpBtn = false
        }else {
            disableSignUpBtn = true
        }
    }
    
    @objc fileprivate func alreadyHaveAccountBtnAction() {
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    @IBAction func profileImgBtnTapped(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        guard let email = txtFields.first(where: {$0.tag == 0})?.text else { return }
        guard let password = txtFields.first(where: {$0.tag == 1})?.text else { return }
        guard let fullName = txtFields.first(where: {$0.tag == 2})?.text else { return }
        guard let username = txtFields.first(where: {$0.tag == 3})?.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print("error in creating user: ",error as Any)
                return
            }
            //upload profile image to firebase storage
            guard let profileImage = self.profileImgBtn.backgroundImage(for: .normal) else{
                print("profile image is nil")
                return
            }
            guard let uploadData = profileImage.jpegData(compressionQuality: 0.3) else {return}
            let fileName = UUID().uuidString
            
            storageRef.child("profile_images").child(fileName).putData(uploadData, metadata: nil, completion: { (metaData, err) in
                if err != nil {
                    print("error in uploading profile image: ",err as Any)
                    return
                }
                guard let path = metaData?.path else{return}
                storageRef.child(path).downloadURL(completion: { (picUrl, urlError) in
                    if urlError != nil {
                        print("error in getting image url: ",urlError as Any)
                        return
                    }
                    guard let url = picUrl?.absoluteString else{return}
                    let userInfo = ["name": fullName, "username": username, "profileImageUrl": url]
                    
                    //saving user info to database
                    let values = [result?.user.uid: userInfo]
                    
                    usersRef.updateChildValues(values, withCompletionBlock: { (userInfoError, databaseRef) in
                        if userInfoError != nil{
                            print("error in saving user data: ",userInfoError as Any)
                            return
                        }
                    })
                })
            })
        }
    }
}

extension SignUpViewController : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        disableSignUpBtn = true
        return true
    }
}

extension SignUpViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        profileImgBtn.setBackgroundImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        imageSelected = true
        formValidation()
        self.dismiss(animated: true, completion: nil)
    }
    
}
