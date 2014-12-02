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
    var playing: Bool = false
    var playlist: Playlist?
    
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
        /*
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.translucent = true
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor(red: 255.0/255.0, green: 40/255.0, blue: 81/255.0, alpha: 1.0)]
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 40/255.0, blue: 81/255.0, alpha: 1.0)
*/
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
        
        
        var songs = self.songs
        var index = self.index
        playlist = Playlist(index: index, songs: songs)

        for var i = index; i < self.playlist?.songs.count; i++ {
            var str = self.playlist?.songs[i].previewUrl
            items.append(AVPlayerItem(URL: NSURL(string: str!)))
        }
        
        self.player = AVQueuePlayer(items: items)
        self.player.play()
        self.playing = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "what", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        //var timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

        initSong(index)

    }
    
    func update() {
        progressView.setProgress(self.counter, animated: true)
        self.counter += 0.003
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initSong(index: Int) {
        self.albumLabel.text = self.songs[index].album
        self.titleLabel.text = self.songs[index].title
        self.artistLabel.text = self.songs[index].artist
        
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
        
        self.player = AVQueuePlayer(items: items)
        initSong(self.index)
        self.player.play()
    }

    @IBAction func play(sender: AnyObject) {
        if playing {
            self.player.pause()
            self.playButton.setTitle("play", forState: UIControlState.Normal)
        } else {
            self.player.play()
            self.playButton.setTitle("||", forState: UIControlState.Normal)
        }
        self.playing = !self.playing
    }
    
    @IBAction func playNext(sender: AnyObject) {
        if self.index + 1 == self.playlist?.songs.count { return }
        self.player.advanceToNextItem()
        self.index++
        initSong(self.index)
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


