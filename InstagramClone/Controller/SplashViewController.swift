//
//  SplashViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 03/09/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class SplashViewController: UIViewController {
    @IBOutlet weak var logoImgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let colorArray = [purple.cgColor, deepPurple.cgColor, indigo.cgColor, blue.cgColor, cyan.cgColor, lightBlue.cgColor]
        
        self.view.setGradientColor(colors: colorArray, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLoginStatus()
    }

    private func checkLoginStatus() {
        if Auth.auth().currentUser == nil {
            print("nil")
            DispatchQueue.main.async {
                self.presentVC(withIdentifier: "RootNavViewController")
            }
            return
        }
        self.presentVC(withIdentifier: "RootHomeTabBarController")
    }

}
