//
//  ImageViewController.swift
//  Cassini
//
//  Created by Victor Shurapov on 10/24/17.
//  Copyright © 2017 VVV. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentSize = imageView.frame.size
            scrollView.delegate = self
            scrollView.minimumZoomScale = 0.03
            scrollView.maximumZoomScale = 1.0
        }
    }
    
    
    private var imageView = UIImageView()
    private var autoZoomed = true
    private var image: UIImage? {
        get { return imageView.image }
        set {
            imageView.image = newValue
            imageView.sizeToFit()
            scrollView?.contentSize = imageView.frame.size
            spinner?.stopAnimating()
            autoZoomed = true
            zoomScaleToFit()
        }
    }
    
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    internal func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        autoZoomed = false
    }
    
    private func fetchImage() {
        guard let url = imageURL else {
            return
        }
        spinner?.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async {
            let imageDataOpt = try? Data(contentsOf: url)
            DispatchQueue.main.async {
                if url == self.imageURL {
                    guard let imageData = imageDataOpt else {
                        self.image = nil
                        return
                    }
                    self.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        zoomScaleToFit()
    }
    
    private func zoomScaleToFit() {
        guard autoZoomed == true else {
            return
        }
        if let sv = scrollView, image != nil && (imageView.bounds.size.width > 0) && (scrollView.bounds.size.width > 0) {
            let widthRatio = scrollView.bounds.size.width / imageView.bounds.size.width
            let heightRatio = scrollView.bounds.size.height / imageView.bounds.size.height
            sv.zoomScale = widthRatio > heightRatio ? widthRatio : heightRatio
            sv.contentOffset = CGPoint(x: (imageView.frame.size.width - sv.frame.size.width) / 2, y: (imageView.frame.size.height - sv.frame.size.height) / 2)
            
        }
    }
}
