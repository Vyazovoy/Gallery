//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Andrew Vyazovoy on 28.11.14.
//  Copyright (c) 2016 Andrew Vyazovoy. All rights reserved.
//

import UIKit

final class GalleryViewController: UIViewController {
    
    private final class PageViewControllerHelper: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        
        var links: [NSURL]
        private let change: (index: Int?) -> Void
        
        init(links: [NSURL], change: (index: Int?) -> Void) {
            self.links = links
            self.change = change
            super.init()
        }
        
        // MARK: - Adopted Protocol Methods
        // MARK: UIPageViewControllerDataSource Methods
        
        @objc func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
            let imageViewController = viewController as? ImageViewController
            
            if let index = imageViewController?.link.flatMap({self.links.indexOf($0)}) {
                if index - 1 >= 0 {
                    let previousImageViewController = ImageViewController()
                    previousImageViewController.link = links[index - 1]
                    
                    return previousImageViewController
                }
            }
            
            return nil;
        }
        
        @objc func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
            let imageViewController = viewController as? ImageViewController
            
            if let index = imageViewController?.link.flatMap({self.links.indexOf($0)}) {
                if index + 1 < links.count {
                    let nextImageViewController = ImageViewController()
                    nextImageViewController.link = links[index + 1]
                    
                    return nextImageViewController
                }
            }
            
            return nil;
        }
        
        // MARK: UIPageViewControllerDelegate Methods
        
        @objc func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
            if completed {
                guard let imageViewController = pageViewController.viewControllers?.first as? ImageViewController else {
                    fatalError("Wrong ViewController in PageViewController")
                }
                change(index: imageViewController.link.flatMap({self.links.indexOf($0)}))
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
    
    private let pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 8])
        pageViewController.view.backgroundColor = UIColor.blackColor()

        return pageViewController
    }()
    
    private lazy var pageViewControllerHelper: PageViewControllerHelper = {
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
    
    private var links: [NSURL] = [] {
        didSet {
            if isViewLoaded() {
                pageViewControllerHelper.links = links
                configurePagesForCurrentLinks()
            }
        }
    }

    private var overlayHidden: Bool = false {
        didSet {
            guard overlayHidden != oldValue else { return }
            let overlayViews = [shareButton, closeButton, infoLabel]
            overlayViews.forEach { $0.hidden = false }
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                overlayViews.forEach { $0.alpha = self.overlayHidden ? 0 : 1 }
                }, completion: { (finished) in
                    overlayViews.forEach { $0.hidden = self.overlayHidden }
            })
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        if #available(iOS 9, *) {
            pageViewController.view.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
            pageViewController.view.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
            pageViewController.view.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
            pageViewController.view.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        } else {
            NSLayoutConstraint(item: pageViewController.view, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: pageViewController.view, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: pageViewController.view, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0.0).active = true
            NSLayoutConstraint(item: pageViewController.view, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0.0).active = true
        }
        pageViewController.didMoveToParentViewController(self)
        pageViewController.delegate = pageViewControllerHelper
        pageViewController.dataSource = pageViewControllerHelper
        configureShareButton()
        configureCloseButton()
        configureInfoLabel()
        configurePagesForCurrentLinks()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
            topLabelConstraint.priority = UILayoutPriorityDefaultLow
            trailingLabelConstraint.priority = UILayoutPriorityDefaultHigh
            horizontalCenterLabelConstraint.priority = UILayoutPriorityDefaultLow
            verticalCenterLabelConstraint.priority = UILayoutPriorityDefaultHigh
        } else {
            topLabelConstraint.priority = UILayoutPriorityDefaultHigh
            trailingLabelConstraint.priority = UILayoutPriorityDefaultLow
            horizontalCenterLabelConstraint.priority = UILayoutPriorityDefaultHigh
            verticalCenterLabelConstraint.priority = UILayoutPriorityDefaultLow
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    // MARK: - Action Methods
    
    @IBAction func buttonTapped(sender: UIButton) {
        switch (sender) {
        case shareButton:
            print("Share")
            
        case closeButton:
            print("Close")
            if let navigationController = navigationController {
                navigationController.popViewControllerAnimated(true)
            } else {
                dismissViewControllerAnimated(true, completion: nil)
            }
            
        default:
            print("Share")
        }
    }
    
    @IBAction func handleGesture(recognizer: UIGestureRecognizer) {
        if recognizer.state == .Ended {
            overlayHidden = !overlayHidden
        }
    }
    
    // MARK: - Custom Methods
    
    func showImages(links: [NSURL]) {
        self.links = links
    }
    
    private func configurePagesForCurrentLinks() {
        let initialImageViewController = pageViewController.viewControllers?.first as? ImageViewController ?? ImageViewController()
        initialImageViewController.link = links.first
        
        pageViewController.setViewControllers([initialImageViewController], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        if links.count > 0 {
            infoLabel.text = "1/\(links.count)"
        } else {
            infoLabel.text = ""
        }
    }
    
    private func configureShareButton() {
        if shareButton == nil {
            let button = UIButton()
            button.tintColor = UIColor.whiteColor()
            button.setImage(UIImage(named: "ShareButtonImage"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-6-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 44.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 44.0))
            shareButton = button
        }
    }
    
    private func configureCloseButton() {
        if closeButton == nil {
            let button = UIButton()
            button.tintColor = UIColor.whiteColor()
            button.setImage(UIImage(named: "CloseButtonImage"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(buttonTapped(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-10-[button]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[button]-6-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["button" : button]))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 44.0))
            button.addConstraint(NSLayoutConstraint(item: button, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 44.0))
            closeButton = button
        }
    }
    
    private func configureInfoLabel() {
        if infoLabel == nil {
            let label = UILabel()
            label.textColor = UIColor.whiteColor()
            label.font = UIFont(name: "Helvetica Neue", size: 16.0)
            label.text = "16/20"
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            topLabelConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-24-[label]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label" : label]).first!
            
            trailingLabelConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:[label]-16-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["label" : label]).first!
            
            horizontalCenterLabelConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
            
            verticalCenterLabelConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: view, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
            
            if traitCollection.verticalSizeClass == UIUserInterfaceSizeClass.Compact {
                topLabelConstraint.priority = UILayoutPriorityDefaultLow
                trailingLabelConstraint.priority = UILayoutPriorityDefaultHigh
                horizontalCenterLabelConstraint.priority = UILayoutPriorityDefaultLow
                verticalCenterLabelConstraint.priority = UILayoutPriorityDefaultHigh
            } else {
                topLabelConstraint.priority = UILayoutPriorityDefaultHigh
                trailingLabelConstraint.priority = UILayoutPriorityDefaultLow
                horizontalCenterLabelConstraint.priority = UILayoutPriorityDefaultHigh
                verticalCenterLabelConstraint.priority = UILayoutPriorityDefaultLow
            }
            view.addConstraints([topLabelConstraint,
                trailingLabelConstraint,
                horizontalCenterLabelConstraint,
                verticalCenterLabelConstraint])
            infoLabel = label
        }
    }
}
