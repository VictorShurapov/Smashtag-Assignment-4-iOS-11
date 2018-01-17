//
//  RecentTableViewController.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 12/7/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit

class RecentTableViewController: UITableViewController {
    
    let recents = RecentSearches()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    private struct Constants {
        static let cellReuseIdentifier = "RecentsCell"
        static let segueIdentifier = "ShowRecentSearch"
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.searches.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier, for: indexPath)
        cell.textLabel?.text = recents.searches[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // remove search string from the data source
            recents.searches.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == Constants.segueIdentifier {
                if let cell = sender as? UITableViewCell {
                    if let ttvc = segue.destination as? TweetTableViewController {
                        ttvc.searchText = cell.textLabel?.text
                    }
                }
            }
        }
    }
}
