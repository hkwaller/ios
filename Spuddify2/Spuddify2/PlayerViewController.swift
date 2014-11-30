//
//  PlayerViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-29.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerViewController: UIViewController {
    var index: Int = 0
    var counter: Float = 0.0
    var songs:[Song] = []
    var items:[AVPlayerItem] = []
    var paused:Bool = false
    var player:AVQueuePlayer = AVQueuePlayer()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var container: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)
        container.layer.cornerRadius = 30;
        
        var songs = self.songs
        var index = self.index
        var playlist = Playlist(index: index, songs: songs)

        for var i = index; i < playlist.songs.count; i++ {
            items.append(AVPlayerItem(URL: NSURL(string: playlist.songs[i].previewUrl)))
        }
        
        self.player = AVQueuePlayer(items: items)
        self.player.play()
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        initFirst()

    }
    
    func update() {
        progressView.setProgress(self.counter, animated: true)
        self.counter += 0.003
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initFirst() {
        self.albumLabel.text = self.songs[index].album
        self.titleLabel.text = self.songs[index].title
        self.artistLabel.text = self.songs[index].artist
        self.imageView.image = self.songs[index].bigImage
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
