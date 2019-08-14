//
//  RootHomeTabBarController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

class RootHomeTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        checkLoginStatus()
        self.delegate = self
    }
    
    fileprivate func checkLoginStatus() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                self.presentVC(withIdentifier: "RootNavViewController")
            }
            return
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            self.presentVC(withIdentifier: "SelectImageNavController", storyboard: "Main", completion: nil)
            return false
        }        
        return true
    }
}
