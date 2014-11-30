//
//  PlayCellTableViewCell.swift
//  Spuddify
//
//  Created by Hannes Waller on 2014-11-19.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import UIKit

class PlayCellTableViewCell: UITableViewCell {

    @IBOutlet weak var song: UILabel!
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadItem(#s: Song) {
        song.text = s.title
        artist.text = s.title
        imgView.image = s.image
    }
    
}
