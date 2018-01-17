//
//  ImageCollectionViewController.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 1/13/18.
//  Copyright © 2018 VVV. All rights reserved.
//

import UIKit

public struct TweetMedia: CustomStringConvertible {
    var tweet: Tweet
    var media: MediaItem
    
    public var description: String {
        return "\(tweet): \(media)"
    }
}

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    
    var tweets: [[Tweet]] = [] {
        didSet {
            images = tweets.flatMap({ $0 })
                .map({ tweet in
                    tweet.media.map({ TweetMedia(tweet: tweet, media: $0) }) }).flatMap({ $0 })
        }
    }
    
    private var images = [TweetMedia]()
    
    private var cache = NSCache<AnyObject, AnyObject>()
    
    private struct Constants {
        static let cellReuseIdentifier = "ImageCell"
        static let segueIdentifier = "ShowTweet"
    }
    
    var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(ImageCollectionViewController.zoom(gesture:))))
    }
    
    @objc func zoom(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            scale *= gesture.scale
            gesture.scale = 1.0
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.segueIdentifier {
            if let ttvc = segue.destination as? TweetTableViewController {
                if let cell = sender as? ImageCollectionViewCell,
                    let tweetMedia = cell.tweetMedia {
                    ttvc.tweets = [[tweetMedia.tweet]]
                }
            }
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellReuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        cell.cache = cache
        
        cell.tweetMedia = images[indexPath.row]
        return cell
    }
    
    
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let ratio = CGFloat(images[indexPath.row].media.aspectRatio)
        let maxCellWidth = collectionView.bounds.size.width
        let sizeSettings = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        var size = CGSize(width: sizeSettings.width * scale, height: sizeSettings.height * scale)
        
        if ratio > 1 {
            size.height /= ratio
        } else {
            size.width *= ratio
        }
        
        if size.width > maxCellWidth {
            size.width = maxCellWidth
            size.height = size.width / ratio
        }
        
        return size
    }
    

}
