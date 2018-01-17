//
//  RootTweetTableViewController.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 12/11/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit

class RootTweetTableViewController: TweetTableViewController {

    @IBAction func backToRoot(segue: UIStoryboardSegue) {}
    
    private struct Storyboard {
        static let MentionsIdentifier = "ShowMentions"
        static let ImagesIdentifier = "ShowImages"
    }
        
    @objc override func showImages(sender: UIBarButtonItem) {
        performSegue(withIdentifier: Storyboard.ImagesIdentifier, sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.MentionsIdentifier:
                if let tweetCell = sender as? TweetTableViewCell {
                    let mtvc = segue.destination as! MentionsTableViewController
                    mtvc.tweet = tweetCell.tweet
                }
            case Storyboard.ImagesIdentifier:
                if let icvc = segue.destination as? ImageCollectionViewController {
                    icvc.tweets = tweets
                    icvc.title = "Images: \(searchText!)"
                }
            default: break
            }
        }
    }

}
