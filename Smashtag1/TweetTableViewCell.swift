//
//  TweetTableViewCell.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 11/22/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    struct Palette {
        static let hashtagColor = UIColor.purple
        static let urlColor = UIColor.blue
        static let userColor = UIColor.orange
    }
    
    func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetProfileImageView?.image = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet {
            tweetTextLabel?.attributedText = setTextLabel(tweet: tweet)
            tweetScreenNameLabel?.text = "\(tweet.user!)" // tweet.user.description
            setProfileImageView(tweet: tweet) // tweetProfileImageView updated asynchronously
            tweetCreatedLabel?.text = setCreatedLabel(tweet: tweet)
        }
    }
    
    private func setTextLabel(tweet: Tweet) -> NSMutableAttributedString {
        var tweetText: String = tweet.text
        for _ in tweet.media { tweetText += "  📷" }
        let attributedText = NSMutableAttributedString(string: tweetText)
        attributedText.setKeywordsColor(keywords: tweet.hashtags, color: Palette.hashtagColor)
        attributedText.setKeywordsColor(keywords: tweet.urls, color: Palette.urlColor)
        attributedText.setKeywordsColor(keywords: tweet.userMentions, color: Palette.userColor)
        return attributedText
    }
    
    private func setProfileImageView(tweet: Tweet) {
        guard let profileImageURL = tweet.user.profileImageURL else {
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let imageDataOpt = try? Data(contentsOf: profileImageURL)
            DispatchQueue.main.async {
                if profileImageURL == self.tweet?.user.profileImageURL {
                    guard let imageData = imageDataOpt else {
                        return
                    }
                    self.tweetProfileImageView?.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    private func setCreatedLabel(tweet: Tweet) -> String {
        let formatter = DateFormatter()
        if Date().timeIntervalSince(tweet.created) > 24 * 60 * 60 {
            formatter.dateStyle = .short
        } else {
            formatter.timeStyle = .short
        }
        return formatter.string(from: tweet.created)
    }
}

// MARK: Extension
private extension NSMutableAttributedString {
    func setKeywordsColor(keywords: [Tweet.IndexedKeyword], color: UIColor) {
        for keyword in keywords {
            addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: keyword.nsrange)
        }
    }
}
