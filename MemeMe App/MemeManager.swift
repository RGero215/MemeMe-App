//
//  MemeManager.swift
//  MemeMe App
//
//  Created by Ramon Geronimo on 11/17/16.
//  Copyright © 2016 Ramon Geronimo. All rights reserved.
//

import Foundation

class MemeManager: NSObject {
    
    class var sharedInstance: MemeManager {
        struct Static {
            static let instance: MemeManager = MemeManager()
        }
               return Static.instance
    }
    
    var memes = [Meme]()
    
    func deleteMemeAtIndex(_ index: Int) {
        memes.remove(at: index)
    }
    
    func appendMeme(_ meme: Meme) {
        memes.append(meme)
    }
}
