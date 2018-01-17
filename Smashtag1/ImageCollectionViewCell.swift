//
//  ImageCollectionViewCell.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 1/13/18.
//  Copyright © 2018 VVV. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var cache: NSCache<AnyObject, AnyObject>?
    var tweetMedia: TweetMedia? {
        didSet {
            imageURL = tweetMedia?.media.url
            fetchImage()
        }
    }
    var imageURL: URL?
    
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            spinner?.stopAnimating()
        }
    }

    private func fetchImage() {
        guard let url = imageURL else {
            return
        }
        spinner?.startAnimating()
        
        var imageData = cache?.object(forKey: imageURL as AnyObject) as? Data
        if imageData != nil {
            self.image = UIImage(data: imageData!)
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            imageData = try? Data(contentsOf: url)
            
            DispatchQueue.main.async {
                if url == self.imageURL {
                    guard imageData != nil else {
                        self.imageURL = nil
                        return
                    }
                    self.image = UIImage(data: imageData!)
                    self.cache?.setObject(imageData! as AnyObject, forKey: self.imageURL! as AnyObject, cost: (imageData! as NSData).length)
                }
            }
        }
    }
}
