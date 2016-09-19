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
    
    fileprivate final class ScrollViewDelegate: NSObject, UIScrollViewDelegate {
        
        fileprivate let zoomableView: UIView
        
        
        init(zoomableView: UIView) {
            self.zoomableView = zoomableView
            super.init()
        }
        // MARK: - Adopted Protocol Methods
        // MARK: UIScrollViewDelegate Methods
        
        @objc func scrollViewDidZoom(_ scrollView: UIScrollView) {
            scrollView.centerizeContent()
        }
        
        @objc func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
            scrollView.panGestureRecognizer.isEnabled = true
            scrollView.alwaysBounceVertical = true
            scrollView.alwaysBounceHorizontal = true
        }
        
        @objc func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            if scrollView.zoomScale == scrollView.minimumZoomScale {
                scrollView.panGestureRecognizer.isEnabled = false
                scrollView.alwaysBounceVertical = false
                scrollView.alwaysBounceHorizontal = false
            }
        }
        
        @objc func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return zoomableView
        }
    }
    
    fileprivate let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bouncesZoom = true
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.black
        return scrollView
    }()
    fileprivate let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.clear
        return imageView
    }()
    fileprivate var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicatorView.startAnimating()
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.transform = CGAffineTransform.identity
            imageView.image = newValue
            imageView.frame = CGRect(origin: CGPoint.zero, size: imageView.image?.size ?? CGSize.zero)
            scrollView.contentSize = imageView.frame.size
            if isViewLoaded {
                view.setNeedsLayout()
                
                if imageView.image != nil {
                    activityIndicatorView.stopAnimating()
                } else {
                    activityIndicatorView.startAnimating()
                }
            }
        }
    }
    
    fileprivate lazy var scrollViewDelegate: ScrollViewDelegate = .init(zoomableView: self.imageView)
    
    var link: URL? = nil {
        didSet {
            if isViewLoaded {
                configureImageViewForCurrentLink()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Did load start")
        view.addSubview(scrollView)
        if #available(iOS 9, *) {
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            NSLayoutConstraint(item: scrollView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: scrollView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        }
        scrollView.addSubview(imageView)
        scrollView.delegate = scrollViewDelegate
        view.addSubview(activityIndicatorView)
        
        if #available(iOS 9, *) {
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        } else {
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: activityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0.0).isActive = true
        }
        configureImageViewForCurrentLink()
        print("Did load finish")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("Layout start")
        configureScrollViewZoomScale()
        scrollView.centerizeContent()
        print("Layout finish  ")
    }
    
    // MARK: - Custom Methods
    
    fileprivate func configureImageViewForCurrentLink() {
        if let currentLink = link {
            SDWebImageManager.shared().downloadImage(with: currentLink, options: .retryFailed, progress: nil, completed: { (image, error, cacheType, completed, imageURL) in
                self.image = image
            })
        } else {
            image = nil
        }
    }
    
    fileprivate func configureScrollViewZoomScale() {
        if let image = image , image.size.height > 0 && image.size.width > 0 {
            let horizontalRatio = scrollView.bounds.size.width / image.size.width
            let verticalRatio = scrollView.bounds.size.height / image.size.height
            scrollView.minimumZoomScale = min(horizontalRatio, verticalRatio)
            scrollView.maximumZoomScale = max(scrollView.minimumZoomScale, scrollView.maximumZoomScale)
        } else {
            scrollView.minimumZoomScale = 1.0
            scrollView.maximumZoomScale = 1.0
        }
        scrollView.zoomScale = scrollView.minimumZoomScale
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.alwaysBounceVertical = false
        scrollView.alwaysBounceHorizontal = false
    }
    
    func prepareForReuse() {
        link = nil
    }
}

private extension UIScrollView {
    
    func centerizeContent() {
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
        
        if let window = window , window.screen.scale < 2.0 {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }
        contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset)
    }
}
