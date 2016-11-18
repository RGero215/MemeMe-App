//
//  Meme.swift
//  MemeMe App
//
//  Created by Ramon Geronimo on 11/17/16.
//  Copyright © 2016 Ramon Geronimo. All rights reserved.
//

import Foundation
import UIKit

struct Meme {
    
    var top:String
    var bottom:String
    var image: UIImage
    var memedImage: UIImage
    
    init(top:String, bottom:String, image:UIImage, memedImage:UIImage){
        self.top = top
        self.bottom = bottom
        self.image = image
        self.memedImage = memedImage
    }
}
