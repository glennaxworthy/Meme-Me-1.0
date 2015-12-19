//
//  MemeMeData.swift
//  MemeMe
//
//  Created by Glenn Axworthy on 12/5/15.
//  Copyright © 2015 Glenn Axworthy. All rights reserved.
//

import UIKit

struct MemeMeData {
    var meme: UIImage! = nil
    var image: UIImage! = nil
    var captionTop: String! = nil
    var captionBottom: String! = nil

    static var memes: [MemeMeData] = [MemeMeData]()

    init(meme: UIImage, image: UIImage, captionTop: String, captionBottom: String) {
        self.meme = meme
        self.image = image
        self.captionTop = captionTop
        self.captionBottom = captionBottom
    }
}
