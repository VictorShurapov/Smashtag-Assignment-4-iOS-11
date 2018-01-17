//
//  ImageTableViewCell.swift
//  Smashtag1
//
//  Created by Victor Shurapov on 11/29/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var imageURL: URL? {
        didSet { updateUI() }
    }
    
    private func updateUI() {
        guard let url = imageURL else {
            return
        }
        spinner?.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            let imageDataOpt = try? Data(contentsOf: url)
            
            DispatchQueue.main.async {
                if url == self.imageURL {
                    guard let imageData = imageDataOpt else {
                        self.imageURL = nil
                        return
                    }
                    self.tweetImage.image = UIImage(data: imageData)
                    self.spinner?.stopAnimating()
                }
            }
        }
    }
}
