//
//  RootViewController.swift
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

class RootViewController: UIViewController {

    @IBOutlet weak var modalButton: UIButton!
    @IBOutlet weak var navigationButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = navigationController {
            navigationController.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(_ sender: UIButton) {
        let galleryViewController = GalleryViewController()
        
        let linkStrings = ["http://fr.academic.ru/pictures/frwiki/77/M101_hires_STScI-PRC2006-10a.jpg",
                           "http://pix-batl.ru/toimg/31/linii_svet_zelenyy_setka_2560x1600.jpg",
                           "http://www.wallpaperzzz.com/wallpapers/hd/hires/big-tree.jpg",
                           "http://www.wallpaperup.com/uploads/wallpapers/2013/01/11/28649/thumb_38f25ce4010e22aecdfd1946a790b9a6.jpg",
                           "http://hqwall.ru/files/40/dym_linii_raznocvetnyy_fon_soedinenie_2560x1600.jpg"]
        let links = linkStrings.flatMap { URL(string: $0) }
        galleryViewController.showImages(links)
        
        if sender == modalButton {
            self.navigationController?.present(galleryViewController, animated: true, completion: nil)
        } else {
            self.navigationController?.show(galleryViewController, sender: self)
        }
    }
}
