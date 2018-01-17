//
//  WebViewController.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 12/22/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit
import WebKit


class WebViewController: UIViewController, WKNavigationDelegate {
    
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: public API
    
    var url: URL?
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
         webView.navigationDelegate = self
        
        if let actualURL = url {
            webView.load(URLRequest(url: actualURL))
            webView.allowsBackForwardNavigationGestures = true
        }
        
        // Add reply button for WebView
        let backButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(WebViewController.actionGoBack(sender:)))
        if let button = navigationItem.rightBarButtonItem {
            navigationItem.rightBarButtonItems = [button, backButton]
        } else {
            navigationItem.rightBarButtonItem = backButton
        }
    }
    
    @objc func actionGoBack(sender: UIBarButtonItem) {
        webView.goBack()
    }

    
    // MARK: - Web View Delegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        spinner.startAnimating()
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        spinner.stopAnimating()
        print("Problems with loading the web page!")
        
    }
}
