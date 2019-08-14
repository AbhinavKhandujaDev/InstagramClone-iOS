//
//  Extensions.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 01/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Firebase

extension UIView {
    func anchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat, height: CGFloat) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            self.rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if width != 0 && width > 0 {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0 && height > 0 {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func addTapGesture(target: Any, selector: Selector) {
        let tapGest = UITapGestureRecognizer()
        tapGest.addTarget(target, action: selector)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGest)
    }
}

extension UIViewController {
    func pushTo<T:UIViewController>(vc: T.Type, storyboard: String = "Main", beforeCompletion: ((T)->(Bool))? = nil, completion:(()->())? = nil) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "\(T.self)") as! T
        let beforeActioncompleted = beforeCompletion?(controller)
        
        if beforeActioncompleted ?? true {
            if self.navigationController != nil {
                self.navigationController?.pushViewController(controller, animated: true)
            }else {
                self.present(controller, animated: true, completion: nil)
            }
        }
        completion?()
    }
    
    func presentVC(withIdentifier: String, storyboard: String = "Main", completion:(()->())? = nil) {
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: withIdentifier)
        self.present(controller, animated: true, completion: nil)
        completion?()
    }
}

extension UITextField {
    func setDefaultTextField(placeHolder: String) {
        self.clearButtonMode = .whileEditing
        self.placeholder = placeHolder
        self.backgroundColor = UIColor(white: 0, alpha: 0.03)
        self.borderStyle = .roundedRect
        self.font = UIFont.systemFont(ofSize: 14)
    }
}

extension String {
    var isValidEmail : Bool {
        let pattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let regex = try! NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}

extension UILabel {
    func setAttributedString(text: String? = "",textAttributes: [NSAttributedString.Key: Any]?, appendText: String? = "", appendTextAttributes: [NSAttributedString.Key: Any]?) {
        let attributedText = NSMutableAttributedString(string: text!, attributes: textAttributes)
        attributedText.append(NSAttributedString(string: appendText!, attributes: appendTextAttributes))
        self.attributedText = attributedText
    }
}

extension DatabaseReference {
    func fetchPost(postId: String, completion: @escaping((Post?)->())) {
        var dict : [String:Any] = [:]
        var post : Post?
        var count = 0
        postRef.child(postId).observe(.childAdded, with: { (ss) in
            dict[ss.key] = ss.value
            post = Post(postId: postId, dict: dict)
            count += 1
            if count == 5 {
                completion(post)
            }
        })
    }
}
