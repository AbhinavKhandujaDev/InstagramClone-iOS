//
//  SelectImageViewController.swift
//  InstagramClone
//
//  Created by abhinav khanduja on 06/08/19.
//  Copyright © 2019 abhinav khanduja. All rights reserved.
//

import UIKit
import Photos

class SelectImageViewController: UIViewController {
    
    fileprivate let selecImgCellIdentifier = "selectImageCell"
    fileprivate let selecImgHeaderIdentifier = "selectImgHeader"
    
    @IBOutlet weak var selectImageCollView: UICollectionView!
    
    fileprivate var padding: CGFloat = 3
    
    fileprivate var horizontalSpace : CGFloat = 3
    fileprivate var verticalSpace : CGFloat = 3
    
    fileprivate var images = [UIImage]()
    fileprivate var assets = [PHAsset]()
    fileprivate var selectedImage : UIImage?
    
    fileprivate var header : SelectImageHeaderViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = selectImageCollView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        }
        configureNavigationButtons()
        fetchPhotos()
    }
    
    fileprivate func configureNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.handlePost))
    }
    
    fileprivate func fetchPhotos() {
        
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        DispatchQueue.global(qos: .background).async {
            allPhotos.enumerateObjects({ (asset, count, stop) in
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true //fetches images in order
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    if let image = image {
                        self.images.append(image)
                        self.assets.append(asset)
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        if count == allPhotos.count - 1 {
                            DispatchQueue.main.async {
                                self.selectImageCollView.reloadData()
                            }
                        }
                    }
                })
            })
        }
    }
    
    fileprivate func getAssetFetchOptions()->PHFetchOptions {
        let options = PHFetchOptions()
        options.fetchLimit = 30
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]
        return options
    }
    
    @objc fileprivate func handlePost() {
        self.pushTo(vc: PostViewController.self, storyboard: "Main", beforeCompletion: { (vc) -> (Bool) in
            vc.image = self.header?.imgView.image
            return true
        }, completion: nil)
    }
    
    @objc fileprivate func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SelectImageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: selecImgCellIdentifier, for: indexPath) as! SelectImageCollectionViewCell
        cell.imageView.image = images[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: selecImgHeaderIdentifier, for: indexPath) as! SelectImageHeaderViewCell
        self.header = header
        if let selectedImage = self.selectedImage {
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 1024, height: 1024)
                
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { (image, info) in
                    header.imgView.image = image
                }
            }
        }

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! SelectImageCollectionViewCell
        selectedImage = cell.imageView.image
        self.selectImageCollView.reloadData()
        
        let indexPth = IndexPath(item: 0, section: 0)
        self.selectImageCollView.scrollToItem(at: indexPth, at: .top, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let rowWidth = (view.frame.width - (horizontalSpace*3)) - 2*padding
        let width = rowWidth/4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return horizontalSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return verticalSpace
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: view.frame.width)
    }
    
}
