//
//  MemeDetailView.swift
//  MemeMe App
//
//  Created by Ramon Geronimo on 1/9/17.
//  Copyright © 2017 Ramon Geronimo. All rights reserved.
//

import UIKit

class MemeDetailView : UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var memeImage : UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let image = memeImage {
            imageView.image = image
        }
    }

}
