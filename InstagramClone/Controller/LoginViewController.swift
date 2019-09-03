//
//  ViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    
    fileprivate let dontHaveAccountBtn : UIButton = {
        let btn = UIButton(type: .system)
        let attrString = NSMutableAttributedString(string: "Dont have an account? ", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attrString.append(NSAttributedString(string: "Sign Up", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        btn.setAttributedTitle(attrString, for: .normal)
        btn.addTarget(self, action: #selector(dontHaveAccountBtnAction), for: .touchUpInside)
        
        return btn
    }()
    
    fileprivate var disableLoginBtn : Bool = true {
        didSet {
            loginBtn.backgroundColor = disableLoginBtn ? UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1) : UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
            loginBtn.isEnabled = disableLoginBtn ? false : true
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true

        emailTxtField.setDefaultTextField(placeHolder: "Email")
        passwordTxtField.setDefaultTextField(placeHolder: "Password")
        loginBtn.layer.cornerRadius = 5
        
        view.addSubview(dontHaveAccountBtn)
        dontHaveAccountBtn.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
        
        [emailTxtField, passwordTxtField].forEach { (field) in
            field!.addTarget(self, action: #selector(logInValidation), for: .editingChanged)
            field!.delegate = self
        }
        
        disableLoginBtn = true
        
//        appDel.setRootVc(vc: nil, storyboard: "Main", vcIdentifier: "RootNavViewController")
    }
    
    @objc fileprivate func logInValidation() {
        guard emailTxtField.hasText, passwordTxtField.hasText else {return}
        if emailTxtField.text!.isValidEmail {
            disableLoginBtn = false
        }else {
            disableLoginBtn = true
        }
    }
    
    @objc fileprivate func dontHaveAccountBtnAction() {
        self.pushTo(vc: SignUpViewController.self)
    }
    
    @IBAction func loginTapped(_ sender: UIButton) {
        view.endEditing(true)
        guard let email = emailTxtField.text, let password = passwordTxtField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (dataResult, dataError) in
            guard let _ = dataResult else {
                print("Sign in error is ",String(dataError.debugDescription.split(separator: "\"")[1]))
                return
            }
            
            self.presentVC(withIdentifier: "RootHomeTabBarController")
        }
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        disableLoginBtn = true
        return true
    }
}

