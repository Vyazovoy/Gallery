//
//  GalleryViewController.swift
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

final class GalleryViewController: UIViewController {
    
    fileprivate final class PageViewControllerHelper: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        var links: [URL]
        fileprivate let change: (_ index: Int?) -> Void
        
        init(links: [URL], change: @escaping (_ index: Int?) -> Void) {
            self.links = links
            self.change = change
            super.init()
        }
        
        // MARK: - Adopted Protocol Methods
        // MARK: UIPageViewControllerDataSource Methods
        
        @objc func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
            let imageViewController = viewController as? ImageViewController
            
            if let index = imageViewController?.link.flatMap({self.links.index(of: $0)}) {
                if index - 1 >= 0 {
                    let previousImageViewController = ImageViewController()
                    previousImageViewController.link = links[index - 1]
                    
                    return previousImageViewController
                }
            }
            
            return nil;
        }
        
        @objc func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
            let imageViewController = viewController as? ImageViewController
            
            if let index = imageViewController?.link.flatMap({self.links.index(of: $0)}) {
                if index + 1 < links.count {
                    let nextImageViewController = ImageViewController()
                    nextImageViewController.link = links[index + 1]
                    
                    return nextImageViewController
                }
            }
            
            return nil;
        }
        
        // MARK: UIPageViewControllerDelegate Methods
        
        @objc func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed {
                guard let imageViewController = pageViewController.viewControllers?.first as? ImageViewController else {
                    fatalError("Wrong ViewController in PageViewController")
                }
                change(imageViewController.link.flatMap({self.links.index(of: $0)}))
            }
        }
    }
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var horizontalCenterLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalCenterLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingLabelConstraint: NSLayoutConstraint!
    
    fileprivate let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 8])
        pageViewController.view.backgroundColor = UIColor.black

        return pageViewController
    }()
    
    fileprivate lazy var pageViewControllerHelper: PageViewControllerHelper = {
        let pageViewControllerHelper = PageViewControllerHelper(links: self.links) { [unowned self] (index) in
            self.overlayHidden = true
            if let index = index {
                self.infoLabel.text = "\(index + 1)/\(self.links.count)"
            } else {
                self.infoLabel.text = ""
            }
        }
        
        return pageViewControllerHelper
    }()
    
    fileprivate var links: [URL] = [] {
        didSet {
            if isViewLoaded {
                pageViewControllerHelper.links = links
                configurePagesForCurrentLinks()
            }
        }
    }

    fileprivate var overlayHidden: Bool = false {
        didSet {
            guard overlayHidden != oldValue else { return }
            let overlayViews = [shareButton, closeButton, infoLabel] as [UIView]
            overlayViews.forEach { $0.isHidden = false }
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
                overlayViews.forEach { $0.alpha = self.overlayHidden ? 0 : 1 }
                }, completion: { (finished) in
                    overlayViews.forEach { $0.isHidden = self.overlayHidden }
            })
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        if #available(iOS 9, *) {
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        } else {
            NSLayoutConstraint(item: pageViewController.view, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: pageViewController.view, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: pageViewController.view, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0).isActive = true
            NSLayoutConstraint(item: pageViewController.view, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0).isActive = true
        }
        pageViewController.didMove(toParentViewController: self)
        pageViewController.delegate = pageViewControllerHelper
        pageViewController.dataSource = pageViewControllerHelper
        configureShareButton()
        configureCloseButton()
        configureInfoLabel()
        configurePagesForCurrentLinks()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact {
            topLabelConstraint.priority = .defaultLow
            trailingLabelConstraint.priority = .defaultHigh
            horizontalCenterLabelConstraint.priority = .defaultLow
            verticalCenterLabelConstraint.priority = .defaultHigh
        } else {
            topLabelConstraint.priority = .defaultHigh
            trailingLabelConstraint.priority = .defaultLow
            horizontalCenterLabelConstraint.priority = .defaultHigh
            verticalCenterLabelConstraint.priority = .defaultLow
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    // MARK: - Action Methods
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        switch (sender) {
        case shareButton:
            print("Share")
            
        case closeButton:
            print("Close")
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true)
            } else {
                dismiss(animated: true, completion: nil)
            }
            
        default:
            print("Share")
        }
    }
    
    @IBAction func handleGesture(_ recognizer: UIGestureRecognizer) {
        if recognizer.state == .ended {
            overlayHidden = !overlayHidden
        }
    }
    
    // MARK: - Custom Methods
    
    func showImages(_ links: [URL]) {
        self.links = links
    }
    
    fileprivate func configurePagesForCurrentLinks() {
        let initialImageViewController = pageViewController.viewControllers?.first as? ImageViewController ?? ImageViewController()
        initialImageViewController.link = links.first
        
        pageViewController.setViewControllers([initialImageViewController], direction: UIPageViewControllerNavigationDirection.forward, animated: false, completion: nil)
        
        if links.count > 0 {
            infoLabel.text = "1/\(links.count)"
        } else {
            infoLabel.text = ""
        }
    }
    
    fileprivate func configureShareButton() {
        if shareButton == nil {
            let button = UIButton()
            button.tintColor = UIColor.white
            button.setImage(UIImage(named: "ShareButtonImage"), for: UIControlState())
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-6-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44.0))
            shareButton = button
        }
    }
    
    fileprivate func configureCloseButton() {
        if closeButton == nil {
            let button = UIButton()
            button.tintColor = UIColor.white
            button.setImage(UIImage(named: "CloseButtonImage"), for: UIControlState())
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: UIControlEvents.touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[button]-6-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 44.0))
            closeButton = button
        }
    }
    
    fileprivate func configureInfoLabel() {
        if infoLabel == nil {
            let label = UILabel()
            label.textColor = UIColor.white
            label.font = UIFont(name: "Helvetica Neue", size: 16.0)
            label.text = "16/20"
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            topLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-24-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label" : label]).first!
            
            trailingLabelConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:[label]-16-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label" : label]).first!
            
            horizontalCenterLabelConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0)
            
            verticalCenterLabelConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0)
            
            if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.compact {
                topLabelConstraint.priority = .defaultLow
                trailingLabelConstraint.priority = .defaultHigh
                horizontalCenterLabelConstraint.priority = .defaultLow
                verticalCenterLabelConstraint.priority = .defaultHigh
            } else {
                topLabelConstraint.priority = .defaultHigh
                trailingLabelConstraint.priority = .defaultLow
                horizontalCenterLabelConstraint.priority = .defaultHigh
                verticalCenterLabelConstraint.priority = .defaultLow
            }
            view.addConstraints([topLabelConstraint,
                trailingLabelConstraint,
                horizontalCenterLabelConstraint,
                verticalCenterLabelConstraint])
            infoLabel = label
        }
    }
}
