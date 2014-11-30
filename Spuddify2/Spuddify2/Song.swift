//
//  Song.swift
//  Spuddify
//
//  Created by Hannes Waller on 2014-11-21.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import Foundation
import UIKit

struct Song {
    var artist: String
    var title: String
    var album: String
    var imgUrl: String
    var previewUrl: String
    var bigUrl: String
    var image: UIImage
    var bigImage: UIImage
    
    init(artist: String, title: String, album: String, imgUrl: String, previewUrl: String, bigUrl: String) {
        self.artist = artist
        self.title = title
        self.album = album
        self.previewUrl = previewUrl
        self.imgUrl = imgUrl
        self.bigUrl = bigUrl
        
        var url:NSURL = NSURL(string: imgUrl)!
        var imageData:NSData = NSData(contentsOfURL: url, options: nil, error: nil)!
        self.image = UIImage(data: imageData)!
        
        var bigData = NSData(contentsOfURL: NSURL(string: bigUrl)!, options: nil, error: nil)!
        
        self.bigImage = UIImage(data: bigData)!
    }
}
