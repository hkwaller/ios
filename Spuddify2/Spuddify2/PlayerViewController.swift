//
//  PlayerViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-29.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//
//  Denne klassen initierer spiller viewet og sørger for at brukeren kan bytte låter og pause
//
//  Merk at det ligger en MPVolumeView for kontroll av volum, denne vil ikke dukke opp i simulatoren, men 
//  kun hvis du kjører appen på telefonen
//

import UIKit
import AVFoundation
import MediaPlayer

// Global player variabel som er tilgjengelig i hele appen
var player: Player = Player()

enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone
    case Pad
}


class PlayerViewController: UIViewController {
    var index: Int = 0
    var counter: Float = 0.0
    var songs:[Song] = []
    var items:[AVPlayerItem] = []
    var timer: NSTimer = NSTimer()
    var timeObserver: AnyObject?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var albumLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backwards: UIButton!
    @IBOutlet weak var forwards: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var centerImage: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var volumeView: UIView!
    @IBOutlet weak var progressSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        navigationItem.title = "Player"
        
        var songs = self.songs
        var index = self.index
        
        if songs.count == 0 {
            self.songs = player.getCurrentSongs()
        }
        
        // Volumeview for kontroll av volumet. Vil ikke dukke opp i simulatoren
        var mpVol: MPVolumeView = MPVolumeView(frame: volumeView.bounds)
        volumeView.addSubview(mpVol)
        
        // Sjekker om det er iPad eller iPhone for å gjemme blur view på pad da bilden synes bra uten den
        // samtidig som den minste bilden blir gjemt
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
            visualEffectView.frame = imageView.frame
            imageView.addSubview(visualEffectView)
        } else if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.centerImage.hidden = true
        }
        
        // Sjekker om spilleren kjører for å vite hva som skal vises i viewet
        if player.playing {
            if index == player.getCurrentIndex() {
                self.songs = player.getCurrentSongs()
                initSong(player.getCurrentIndex())
            } else {
                initSong(index)
                player.loadSongs(self.songs, index: index)
            }
        } else {
            player.loadSongs(self.songs, index: index)
            initSong(index)
        }
        
        // Timer for visning av hvor langt en sang er kommet
        var interval: CMTime = CMTimeMake(1, 30)
        self.timeObserver = player.addPeriodicTimeObserverForInterval(interval, queue: nil) { (time: CMTime) -> Void in
            self.update()
        }

        initButtons()
    }
    
    // Legger til en observer for når en sang er ferdig
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "goToNext", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    // Initierer de forskjellige knappene
    func initButtons() {
        backwards.layer.cornerRadius = 35;
        forwards.layer.cornerRadius = 35;
        playButton.layer.cornerRadius = 35;
        
        self.progressSlider.setThumbImage(UIImage(named: "thumb.png")!, forState: .Normal)
        
        playButton.layer.borderWidth = 2.0
        playButton.layer.borderColor = UIColor.blackColor().CGColor
        backwards.layer.borderWidth = 2.0
        backwards.layer.borderColor = UIColor.blackColor().CGColor
        forwards.layer.borderWidth = 2.0
        forwards.layer.borderColor = UIColor.blackColor().CGColor
    }
    
    // Inaktiverer timeren og tar vekk observern når brukeren går vekk fra viewet
    override func viewDidDisappear(animated: Bool) {
        self.timer.invalidate()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Funksjonen som kjøres av observern på tid, slik at progressSlidern rører på seg
    func update() {
        if player.player.currentItem != nil {
            var item: AVPlayerItem = player.getCurrentItem()
            var sec = CMTimeGetSeconds(item.currentTime())
            self.progressSlider.value = Float(sec)
        }
    }
    
    func goToNext() {
        playNext(self)
    }
    
    // Funksjon som setter visning av sang i viewet, plus initierer timeren
    func initSong(index: Int) {
        if player.getCurrentIndex() == player.getCurrentSongs().count { return }
        self.albumLabel.text = player.getCurrentSongs()[index].album
        self.titleLabel.text = player.getCurrentSongs()[index].title
        self.artistLabel.text = player.getCurrentSongs()[index].artist
        setDefaults()
        var url = NSURL(string: player.getCurrentSongs()[index].bigUrl)
        var imgData = NSData(contentsOfURL: url!)
        self.imageView.image = UIImage(data: imgData!)
        self.centerImage.image = UIImage(data: imgData!)
        self.timer.invalidate()
        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        self.timer.fire()
        self.progressSlider.value = 0.0
    }

    @IBAction func playPrevious(sender: AnyObject) {
        player.previousSong()
        initSong(player.getCurrentIndex())
    }

    @IBAction func play(sender: AnyObject) {
        player.togglePlayer()
        if !player.playing {
            self.playButton.setTitle("play", forState: UIControlState.Normal)
        } else {
            self.playButton.setTitle("||", forState: UIControlState.Normal)
        }
    }
    
    @IBAction func playNext(sender: AnyObject) {
        player.nextSong()
        initSong(player.getCurrentIndex())
    }
    
    // Setter defaults for en spilt sang som vises i today-extension
    func setDefaults() {
        var sharedDefaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Westerdals.SpuddifySharingDefaults")!;
        sharedDefaults.setValue(self.songs[index].artist, forKey: "artist")
        sharedDefaults.setValue(self.songs[index].album, forKey: "album")
        sharedDefaults.setValue(self.songs[index].title, forKey: "title")
        sharedDefaults.synchronize()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}


