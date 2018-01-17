//
//  MentionsTableViewController.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 11/29/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit

class MentionsTableViewController: UITableViewController {
    
    // MARK: - Public API
    
    var tweet: Tweet? {
        didSet {
            //title = tweet?.user.screenName
            if let media = tweet?.media, media.count > 0 {
                mentionTypes.append(MentionType(type: "Images", mentions: media.map { Mention.Image($0.url, $0.aspectRatio) }))
            }
            if let urls = tweet?.urls, urls.count > 0 {
                mentionTypes.append(MentionType(type: "URLs", mentions: urls.map { Mention.Keyword($0.keyword) }))
            }
            if let hashtags = tweet?.hashtags, hashtags.count > 0 {
                mentionTypes.append(MentionType(type: "Hashtags", mentions: hashtags.map { Mention.Keyword($0.keyword) }))
            }
            if let users = tweet?.userMentions {
                var userItems = [Mention.Keyword("@" + tweet!.user.screenName)]
                if users.count > 0 {
                    userItems += users.map { Mention.Keyword($0.keyword) }
                }
                mentionTypes.append(MentionType(type: "Users", mentions: userItems))
            }
        }
    }
    
    // MARK: - Internal Data Structure
    
    private var mentionTypes = [MentionType]()
    private struct MentionType: CustomStringConvertible{
        var type: String
        var mentions: [Mention]
        
        var description: String { return "\(type): \(mentions)" }
    }
    private enum Mention: CustomStringConvertible {
        case Keyword(String)
        case Image(URL, Double)
        
        var description: String {
            switch self {
            case .Keyword(let keyword):
                return keyword
            case .Image(let url, _):
                return url.path
            }
        }
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    // MARK: - Table view data source
    
    private struct Storyboard {
        static let KeywordCellReuseIdentifier = "KeywordCell"
        static let ImageCellReuseIdentifier = "ImageCell"
        static let KeywordSegueIdentifier = "FromKeyword"
        static let ImageSegueIdentifier = "ShowImage"
        static let WebSegueIdentifier = "ShowURL"
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionTypes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return mentionTypes[section].mentions.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mention = mentionTypes[indexPath.section].mentions[indexPath.row]
        
        switch mention {
        case .Image(_, let ratio):
            return tableView.bounds.size.width / CGFloat(ratio)
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionTypes[section].type
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mention = mentionTypes[indexPath.section].mentions[indexPath.row]
        
        switch mention {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.KeywordCellReuseIdentifier, for: indexPath)
            cell.textLabel?.text = keyword
            return cell
            
        case .Image(let url, let ratio):
            let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.ImageCellReuseIdentifier, for: indexPath) as! ImageTableViewCell
            cell.imageURL = url
            return cell
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.KeywordSegueIdentifier:
                if let ttvc = segue.destination as? TweetTableViewController,
                    let cell = sender as? UITableViewCell {
                    var text = cell.textLabel?.text
                    if text != nil {
                        if text!.hasPrefix("@") {
                            text! += " OR from:" + text!
                        }
                    }
                    ttvc.searchText = text
                }
            case Storyboard.ImageSegueIdentifier:
                if let ivc = segue.destination as? ImageViewController,
                    let cell = sender as? ImageTableViewCell {
                    ivc.imageURL = cell.imageURL
                    ivc.title = title
                }
            case Storyboard.WebSegueIdentifier:
                if let wvc = segue.destination as? WebViewController {
                    if let cell = sender as? UITableViewCell {
                        if let url = cell.textLabel?.text {
                            wvc.url = URL(string: url)
                        }
                    }
                }
            default: break
            }
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == Storyboard.KeywordSegueIdentifier {
            if let cell = sender as? UITableViewCell,
                let url = cell.textLabel?.text,
                url.hasPrefix("http") || url.hasPrefix("https") {
               // UIApplication.shared.open(URL(string: url)!)
                performSegue(withIdentifier: Storyboard.WebSegueIdentifier, sender: sender)
                return false
            }
        }
        return true
    }
}
