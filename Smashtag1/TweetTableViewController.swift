
//
//  TweetTableViewController.swift
//  SmashTag
//
//  Created by Victor Shurapov on 11/7/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit


class TweetTableViewController: UITableViewController, UITextFieldDelegate {
    
    // MARK: - Public API
    
    var tweets = [[Tweet]]()
    
    var searchText: String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData()
            refresh()
            
        }
    }
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // tableView.estimatedRowHeight = tableView.rowHeight
        // tableView.rowHeight = UITableViewAutomaticDimension
        if tweets.count == 0 {
            refresh()
            // adding imageButton as rightBarButtonItem
            let imageButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(RootTweetTableViewController.showImages(sender:)))
            if let existingButton = navigationItem.rightBarButtonItem {
                navigationItem.rightBarButtonItems = [existingButton, imageButton]
            } else {
                navigationItem.rightBarButtonItem = imageButton
            }
        } else {
            // for single-tweet case
            searchTextField.text = " "
            let tweet = tweets.first!.first!
            title = "Tweet by " + tweet.user.name
            tableView.reloadSections(IndexSet(0..<tableView.numberOfSections), with: .none)
        }
    }
    @objc func showImages(sender: UIBarButtonItem) {
        performSegue(withIdentifier: Storyboard.ImagesIdentifier, sender: sender)
    }
    
    // MARK: - Refreshing
    
    private var lastSuccessfulRequest: TwitterRequest?
    
    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction private func refresh(_ sender: UIRefreshControl?) {
        if searchText != nil {
            RecentSearches().add(searchQuery: searchText!)
            if let request = nextRequestToAttempt {
                request.fetchTweets { newTweets in
                    DispatchQueue.main.async {
                        if newTweets.count > 0 {
                            self.lastSuccessfulRequest = request
                            self.tweets.insert(newTweets, at: 0)
                            self.tableView.reloadData()
                            sender?.endRefreshing()
                        } else {
                            sender?.endRefreshing()
                        }
                    }
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func refresh() {
        if refreshControl != nil {
            refreshControl?.beginRefreshing()
        }
        refresh(refreshControl)
    }
    
    // MARK: - Storyboard Connectivity
    
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
        static let MentionsSegueIdentifier = "ShowMentions"
        static let ImagesIdentifier = "ShowImages"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return tweets.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweets[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Storyboard.CellReuseIdentifier, for: indexPath) as! TweetTableViewCell
        
        // Configure the cell...
        cell.tweet = tweets[indexPath.section][indexPath.row]
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case Storyboard.MentionsSegueIdentifier:
                if let cell = sender as? TweetTableViewCell {
                    let mtvc = segue.destination as! MentionsTableViewController
                    mtvc.tweet = cell.tweet
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
