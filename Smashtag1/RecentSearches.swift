//
//  RecentSearches.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 12/7/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import Foundation

class RecentSearches {
    
    private struct Constants {
        static let SearchesKey = "RecentSearches.Values"
        static let MaxSearches = 100
    }
    
    private let defaults = UserDefaults.standard
    
    var searches: [String] {
        get { return defaults.object(forKey: Constants.SearchesKey) as? [String] ?? [] }
        set { defaults.set(newValue, forKey: Constants.SearchesKey) }
    }
    
    func add(searchQuery: String) {
        var currentSearches = searches
        if let index =  currentSearches.index(of: searchQuery) {
            currentSearches.remove(at: index)
        }
        currentSearches.insert(searchQuery, at: 0)
        while currentSearches.count > Constants.MaxSearches {
            currentSearches.removeLast()
        }
        searches = currentSearches
    }
    
    func removeAtIndex(index: Int) {
        var currentSearches = searches
        currentSearches.remove(at: index)
        searches = currentSearches
    }
}
