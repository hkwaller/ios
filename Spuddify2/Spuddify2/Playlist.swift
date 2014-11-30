
//
//  Playlist.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-29.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import Foundation
import UIKit

struct Playlist {
    var index: Int
    var songs: [Song]
    
    init(index: Int, songs: [Song]) {
        self.index = index
        self.songs = songs
    }
}

