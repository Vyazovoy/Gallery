//
//  ImageViewController.swift
//  Gallery
//
//  Created by Andrew Vyazovoy on 28.11.14.
//  Copyright (c) 2014 My Corp. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    var link: NSURL? = nil {
        didSet {
            if isViewLoaded() {
                configureImageViewForCurrentLink()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        configureImageViewForCurrentLink()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        correctMinZoomScale()
        scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
    }
    
    // MARK: - Adopted Protocol Methods
    // MARK: UIScrollViewDelegate Methods
    
    func scrollViewDidZoom(scrollView: UIScrollView) {
        configureImageViewConstraints()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - Custom Methods
    
    private func configureImageViewForCurrentLink() {
        if let currentLink = link {
            activityIndicatorView.startAnimating()
            imageView.sd_setImageWithURL(currentLink, placeholderImage: nil, options: SDWebImageOptions.RetryFailed | SDWebImageOptions.ScaleToScreen, completed: { (image, error, cacheType, imageURL) -> Void in
                if image != nil {
                    println("\(image.scale)")
                }
                self.correctMinZoomScale()
                self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
                self.activityIndicatorView.stopAnimating()
            })
        } else {
            imageView.sd_cancelCurrentImageLoad()
            imageView.image = nil
            activityIndicatorView.stopAnimating()
        }
        correctMinZoomScale()
        scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: false)
    }
    
    private func configureImageViewConstraints() {
        let imageViewWidth = imageView.intrinsicContentSize().width
        let imageViewHeight = imageView.intrinsicContentSize().height
        let scrollWidth = scrollView.frame.size.width
        let scrollHeight = scrollView.frame.size.height
        
        let horizontalSpace = (scrollWidth - scrollView.zoomScale * imageViewWidth) / 2.0
        let verticalSpace = (scrollHeight - scrollView.zoomScale * imageViewHeight) / 2.0
        
        leadingConstraint.constant = max(0.0, horizontalSpace)
        trailingConstraint.constant = max(0.0, horizontalSpace)
        
        topConstraint.constant = max(0.0, verticalSpace)
        bottomConstraint.constant = max(0.0, verticalSpace)
    }
    
    private func correctMinZoomScale() {
        let originalZoomScale = scrollView.zoomScale
        
        if let image = imageView.image {
            let horizontalRatio = scrollView.frame.size.width / image.size.width
            let verticalRatio = scrollView.frame.size.height / image.size.height
            let minRatio = min(horizontalRatio, verticalRatio)
            let minZoomScale = min(minRatio, scrollView.maximumZoomScale)
            scrollView.minimumZoomScale = minZoomScale
            
            if scrollView.zoomScale < scrollView.minimumZoomScale || scrollView.zoomScale > scrollView.maximumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: false)
            }
        } else {
            scrollView.maximumZoomScale = 1.0
            scrollView.minimumZoomScale = 1.0
            scrollView.setZoomScale(1.0, animated: false)
        }
        
        if scrollView.zoomScale == originalZoomScale {
            configureImageViewConstraints()
        }
    }
    
    func prepareForReuse() {
        link = nil
    }
}
