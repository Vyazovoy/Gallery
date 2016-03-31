//
//  GalleryViewController.swift
//  Gallery
//
//  Created by Andrew Vyazovoy on 28.11.14.
//  Copyright (c) 2014 My Corp. All rights reserved.
//

import UIKit

let UILayoutPriorityDefaultHigh : UILayoutPriority = 750.0
let UILayoutPriorityDefaultLow : UILayoutPriority = 250.0

class GalleryPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var horizontalCenterLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var verticalCenterLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLabelConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingLabelConstraint: NSLayoutConstraint!
    
    private var imageViewControllerPool = [ImageViewController]()
    private var links: [NSURL] = [] {
        didSet {
            if isViewLoaded() {
                configurePagesForCurrentLinks()
            }
        }
    }
    private var overlayHidden: Bool = false {
        didSet {
            if overlayHidden != oldValue {
                if !self.overlayHidden {
                    self.shareButton.hidden = false
                    self.closeButton.hidden = false
                    self.infoLabel.hidden = false
                    self.shareButton.alpha = 0.0
                    self.closeButton.alpha = 0.0
                    self.infoLabel.alpha = 0.0
                }
                UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
                    self.shareButton.alpha = self.overlayHidden ? 0.0 : 1.0
                    self.closeButton.alpha = self.overlayHidden ? 0.0 : 1.0
                    self.infoLabel.alpha = self.overlayHidden ? 0.0 : 1.0
                }, completion: { (finished) -> Void in
                    if self.overlayHidden {
                        self.shareButton.hidden = false
                        self.closeButton.hidden = false
                        self.infoLabel.hidden = false
                    }
                })
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        configureShareButton()
        configureCloseButton()
        configureInfoLabel()
        configurePagesForCurrentLinks()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(tapRecognizer)
        view.backgroundColor = UIColor(white: 41.0 / 255.0, alpha: 1.0)
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
    
    // MARK: - Adopted Protocol Methods
    // MARK: UIPageViewControllerDataSource Methods
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let imageViewController = viewController as? ImageViewController
        
        if let index = imageViewController?.link.flatMap({self.links.indexOf($0)}) {
            if index - 1 >= 0 {
                let previousImageViewController = dequeueImageViewController()
                previousImageViewController?.link = links[index - 1]
                
                return previousImageViewController
            }
        }
        
        return nil;
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let imageViewController = viewController as? ImageViewController
        
        if let index = imageViewController?.link.flatMap({self.links.indexOf($0)}) {
            if index + 1 < links.count {
                let nextImageViewController = dequeueImageViewController()
                nextImageViewController?.link = links[index + 1]
                
                return nextImageViewController
            }
        }
        
        return nil;
    }
    
    // MARK: UIPageViewControllerDelegate Methods
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            overlayHidden = true
            let imageViewController = viewControllers?.first as? ImageViewController
            
            if let index = imageViewController?.link.flatMap({self.links.indexOf($0)}) {
                infoLabel.text = "\(index + 1)/\(links.count)"
            } else {
                infoLabel.text = ""
            }
        }
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
        var initialImageViewController = viewControllers?.first as? ImageViewController
        
        if initialImageViewController == nil {
            initialImageViewController = dequeueImageViewController()
        }
        
        if let viewController = initialImageViewController {
            viewController.link = links.first
        }
        
        setViewControllers((initialImageViewController != nil ? [initialImageViewController!] : []), direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)
        
        if links.count > 0 {
            infoLabel.text = "1/\(links.count)"
        } else {
            infoLabel.text = ""
        }

    }
    
    private func dequeueImageViewController() -> ImageViewController? {
        var imageViewController: ImageViewController?
        
        for viewController in imageViewControllerPool {
            if viewController.parentViewController == nil {
                viewController.prepareForReuse()
                imageViewController = viewController
                break
            }
        }
        
        if imageViewController == nil {
            imageViewController = storyboard?.instantiateViewControllerWithIdentifier("ImageViewController") as? ImageViewController
            //webPageController.delegate = self
            if let viewController = imageViewController {
                imageViewControllerPool.append(viewController)
            }
        }
        
        return imageViewController
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
