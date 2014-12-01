//
//  RootViewController.swift
//  Gallery
//
//  Created by Andrew Vyazovoy on 28.11.14.
//  Copyright (c) 2014 My Corp. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    @IBOutlet weak var modalButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(sender: UIButton) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("GalleryPageViewController") as? GalleryPageViewController
        
        if let galleryPageViewController = viewController {
            let linkStrings = ["http://fr.academic.ru/pictures/frwiki/77/M101_hires_STScI-PRC2006-10a.jpg",
                               "http://www.turbophoto.com/space/webart/sunb-hires.jpg",
                               "http://www.wallpaperzzz.com/wallpapers/hd/hires/big-tree.jpg",
                               "http://www.turbophoto.com/hires/shuttle2-hires.jpeg",
                               "http://blog.dannyweeks.com/wp-content/uploads/2013/08/Saturns-moon-Enceladus-hires-Desktop-Wallpaper.jpg"]
            let links = linkStrings.map { NSURL(string: $0) }.reduce([NSURL]()) { acc, value in
                if let value = value {
                    return acc + [value]
                } else {
                    return acc
                }
            }
            galleryPageViewController.showImages(links)
            
            if sender == modalButton {
                self.navigationController?.presentViewController(galleryPageViewController, animated: true, completion: nil)
            } else {
                self.navigationController?.showViewController(galleryPageViewController, sender: self)
            }
        }
    }
}
