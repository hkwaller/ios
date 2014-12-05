//
//  PlayerViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-29.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import UIKit
import AVFoundation


extension AVQueuePlayer {
    var playing: Bool {
        if self.rate > 0.1 {
            return true
        }
        return false
    }
}

var player: AVQueuePlayer = AVQueuePlayer()

class PlayerViewController: UIViewController {
    var index: Int = 0
    var counter: Float = 0.0
    var songs:[Song] = []
    var items:[AVPlayerItem] = []
    var playlist: Playlist?
    var timer: NSTimer = NSTimer()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var smallImage: UIImageView!
    @IBOutlet weak var backwards: UIButton!
    @IBOutlet weak var forwards: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background.png")!)

        container.layer.cornerRadius = 30;
        container.layer.borderWidth = 2.0
        container.layer.borderColor = UIColor.blackColor().CGColor
        backwards.layer.cornerRadius = 35;
        forwards.layer.cornerRadius = 35;
        playButton.layer.cornerRadius = 35;
        
        playButton.layer.borderWidth = 2.0
        playButton.layer.borderColor = UIColor.blackColor().CGColor
        backwards.layer.borderWidth = 2.0
        backwards.layer.borderColor = UIColor.blackColor().CGColor
        forwards.layer.borderWidth = 2.0
        forwards.layer.borderColor = UIColor.blackColor().CGColor
        
        navigationItem.title = "Player"
        var songs = self.songs
        var index = self.index
        playlist = Playlist(index: index, songs: songs)

        for var i = index; i < self.playlist?.songs.count; i++ {
            var str = self.playlist?.songs[i].previewUrl
            items.append(AVPlayerItem(URL: NSURL(string: str!)))
        }
        
        player = AVQueuePlayer(items: items)
        player.play()

        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToNext", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

        initSong(index)

    }
    
    override func viewDidDisappear(animated: Bool) {
        self.timer.invalidate()
    }
    
    func update() {
        progressView.setProgress(self.counter, animated: true)
        self.counter += 0.003
    }
    
    func goToNext() {
        initSong(self.index)
        playNext(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initSong(index: Int) {
        self.albumLabel.text = self.songs[index].album
        self.titleLabel.text = self.songs[index].title
        self.artistLabel.text = self.songs[index].artist
        setDefaults()
        var url = NSURL(string: self.songs[index].bigUrl)
        var imgData = NSData(contentsOfURL: url!)
        self.imageView.image = UIImage(data: imgData!)
    }

    @IBAction func playPrevious(sender: AnyObject) {
        if self.index - 1 < 0 { return }
        self.index--
        self.items = []
        
        for var i = self.index; i < self.playlist?.songs.count; i++ {
            var str = self.playlist?.songs[i].previewUrl
            self.items.append(AVPlayerItem(URL: NSURL(string: str!)))
        }
        
        player = AVQueuePlayer(items: items)
        initSong(self.index)
        player.play()
    }

    @IBAction func play(sender: AnyObject) {        
        if player.playing {
            player.pause()
            self.playButton.setTitle("play", forState: UIControlState.Normal)
        } else {
            player.play()
            self.playButton.setTitle("||", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playNext(sender: AnyObject) {
        if self.index + 1 == self.playlist?.songs.count { return }
        player.advanceToNextItem()
        self.index++
        initSong(self.index)
    }
    
    func setDefaults() {
        var sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Westerdals.SpuddifySharingDefaults")!;
        sharedDefaults.setValue(self.songs[index].artist, forKey: "artist")
        sharedDefaults.setValue(self.songs[index].album, forKey: "album")
        sharedDefaults.setValue(self.songs[index].title, forKey: "title")

        sharedDefaults.synchronize()
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


