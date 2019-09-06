//
//  CommentInputTextView.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 05/09/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit

class CommentInputTextView: UITextView {
    
    let placeHolderLabel : UILabel = {
        let lbl = UILabel()
        lbl.text = "Enter comment..."
        lbl.textColor = .lightGray
        return lbl
    }()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleInputTextDidChange), name: UITextView.textDidChangeNotification, object: nil)
        
        addSubview(placeHolderLabel)
        placeHolderLabel.anchor(top: nil, left: leftAnchor, bottom: nil, right: rightAnchor, paddingTop: 8, paddingLeft: 8, paddingBottom: 0, paddingRight: 0, width: 0, height: 0)
        placeHolderLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleInputTextDidChange() {
        placeHolderLabel.isHidden = !self.text.isEmpty
    }
    
}
