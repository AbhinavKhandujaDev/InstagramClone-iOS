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
    
    private var notifIds = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        observeNotifs()
    }
    
    private func observeNotifs() {
        guard let currUser = Auth.auth().currentUser?.uid else { return }
        notificationsRef.child(currUser).observeSingleEvent(of: .value) { (ss) in
            guard let allObjects = ss.children.allObjects as? [DataSnapshot] else {return}
            
            allObjects.forEach({ (object) in
                let notifId = object.key
                notificationsRef.child(currUser).child(notifId).child("checked").observeSingleEvent(of: .value, with: { (checkedSS) in
                    guard let checked = checkedSS.value as? Int else {return}
                    if checked == 0 {
                        self.tabBar.items?[3].badgeValue = "" //shows only red dot
                    }else {
                        self.tabBar.items?[3].badgeValue = nil
                    }
                })
            })
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            self.presentVC(withIdentifier: "SelectImageNavController", storyboard: "Main", completion: nil)
            return false
        }else if index == 3 {
            self.tabBar.items?[3].badgeValue = nil
        }
        return true
    }
}
