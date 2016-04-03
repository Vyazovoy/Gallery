//
//  ImageViewController.swift
//  Gallery
//
//  Created by Andrew Vyazovoy on 28.11.14.
//  Copyright (c) 2014 - 2016 Andrew Vyazovoy (andrew.vyazovoy@gmail.com)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import WebImage

final class ImageViewController: UIViewController {
    
    private final class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
        
        private let zoomableView: UIView
        
        
        init(zoomableView: UIView) {
            self.zoomableView = zoomableView
            super.init()
        }
        // MARK: - Adopted Protocol Methods
        // MARK: UIScrollViewDelegate Methods
        
        @objc func scrollViewDidZoom(scrollView: UIScrollView) {
            scrollView.centerContent()
        }
        
        @objc func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView?) {
            scrollView.panGestureRecognizer.enabled = true
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
        }
        
        @objc func scrollViewDidEndZooming(scrollView: UIScrollView, withView view: UIView?, atScale scale: CGFloat) {
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                scrollView.panGestureRecognizer.enabled = false
                scrollView.alwaysBounceVertical = false
                scrollView.alwaysBounceHorizontal = false
            }
        }
        
        @objc func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
            return zoomableView
        }
    }
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bouncesZoom = true
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.blackColor()
        return scrollView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clearColor()
        return imageView
    }()
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.transform = CGAffineTransformIdentity
            imageView.image = newValue
            imageView.frame = CGRect(origin: CGPointZero, size: imageView.image?.size ?? CGSizeZero)
            scrollView.contentSize = imageView.frame.size
            if isViewLoaded() {
                view.setNeedsLayout()
                
                if imageView.image != nil {
                    activityIndicatorView.stopAnimating()
                } else {
                    activityIndicatorView.startAnimating()
                }
            }
        }
    }
    
    private lazy var scrollViewDelegate: ScrollViewDelegate = {
        let scrollViewDelegate = ScrollViewDelegate(zoomableView: self.imageView)
        return scrollViewDelegate
    }()
    
    var link: NSURL? = nil {
        didSet {
            if isViewLoaded() {
                configureImageViewForCurrentLink()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Did load start")
        view.addSubview(scrollView)
        if #available(iOS 9, *) {
            scrollView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
            scrollView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
            scrollView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
            scrollView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        } else {
            NSLayoutConstraint(item: scrollView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: scrollView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: scrollView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: scrollView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0).active = true
        }
        scrollView.addSubview(imageView)
        scrollView.delegate = scrollViewDelegate
        view.addSubview(activityIndicatorView)
        
        if #available(iOS 9, *) {
            activityIndicatorView.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
            activityIndicatorView.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        } else {
            NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterX, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: activityIndicatorView, attribute: .CenterX, relatedBy: .Equal, toItem: view, attribute: .CenterY, multiplier: 1.0, constant: 0.0).active = true
        }
        configureImageViewForCurrentLink()
        print("Did load finish")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Layout start")
        configureScrollViewZoomScale()
        scrollView.centerContent()
        print("Layout finish  ")
    }
    
    // MARK: - Custom Methods
    
    private func configureImageViewForCurrentLink() {
        if let currentLink = link {
            SDWebImageManager.sharedManager().downloadImageWithURL(currentLink, options: .RetryFailed, progress: nil, completed: { (image, error, cacheType, completed, imageURL) in
                self.image = image
            })
        } else {
            image = nil
        }
    }
    
    private func configureScrollViewZoomScale() {
        if let image = image where image.size.height > 0 && image.size.width > 0 {
            let horizontalRatio = scrollView.bounds.size.width / image.size.width
            let verticalRatio = scrollView.bounds.size.height / image.size.height
            scrollView.minimumZoomScale = min(horizontalRatio, verticalRatio)
            scrollView.maximumZoomScale = max(scrollView.minimumZoomScale, scrollView.maximumZoomScale)
        } else {
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 1.0
        }
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.panGestureRecognizer.enabled = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
    }
    
    func prepareForReuse() {
        link = nil
    }
}

private extension UIScrollView {
    
    func centerContent() {
        var horizontalInset: CGFloat
        var verticalInset: CGFloat
        
        if contentSize.width < bounds.width {
            horizontalInset = (bounds.width - contentSize.width) * 0.5
        } else {
            horizontalInset = 0.0
        }
        
        if contentSize.height < bounds.height {
            verticalInset = (bounds.height - contentSize.height) * 0.5
        } else {
            verticalInset = 0.0
        }
        
        if let window = window where window.screen.scale < 2.0 {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }
        contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}
