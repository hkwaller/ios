//
//  ViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-24.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, ShareDataDelegate {
    var songs: [Song] = []
    var imageCache = [String : UIImage]()
    var dataHandler: DataHandler = DataHandler()
    let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var barButtonPlayer: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        self.songs = dataHandler.getCoreData(appDel)
        
        if songs.count == 0 { self.tableView.hidden = true }
        
        searchButton.layer.cornerRadius = 30;
        
        var nib = UINib(nibName: "PlayCellTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateGlobalIndex", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)

    }
    
    override func viewDidAppear(animated: Bool) {
        if player.playing {
            barButtonPlayer.enabled = true
        } else {
            barButtonPlayer.enabled = false
        }
    }
    
    func updateGlobalIndex() {
        if currentIndex != currentSongs.count - 1 { currentIndex++ }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PlayCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as PlayCellTableViewCell
        let song = songs[indexPath.row]
        
        cell.loadItem(s: song, type: .Playlist)
        
        let urlString = song.imgUrl as String
        var image = self.imageCache[urlString]
        
        if (image == nil) {
            var imgURL: NSURL = NSURL(string: urlString)!
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? PlayCellTableViewCell {
                            cellToUpdate.imgView.image = image
                        }
                    })
                }
                else {
                    println(error.localizedDescription)
                }
            })
            
        }
        else {
            dispatch_async(dispatch_get_main_queue(), {
                if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) as? PlayCellTableViewCell {
                    cellToUpdate.imgView.image = image
                }
            })
        }
        
        
        return cell
    }
    
    @IBAction func toPlayerWithButton(sender: AnyObject) {
        self.performSegueWithIdentifier("toPlayerWithButton", sender: self)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if Reachability.isConnectedToNetwork() {
            self.performSegueWithIdentifier("goToPlayer", sender:self)
        } else {
            let alert = SCLAlertView()
            alert.showWarning("No internet connection", subTitle: "Please connect to the internet", closeButtonTitle: "OK", duration: 3.0)
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            dataHandler.deleteSongFromCore(self.songs[indexPath.row])

            var tempSong = self.songs[indexPath.row] as Song
            var tempURL = NSURL(string: tempSong.previewUrl)
            var tempItem = AVPlayerItem(URL: tempURL)!
            
            for x in player.items() {
                var asset: AVAsset = x.asset
                var urlAsset = asset as AVURLAsset
                if tempURL == urlAsset.URL {
                    player.removeItem(x as AVPlayerItem)
                }
            }
            
            self.songs.removeAtIndex(indexPath.row)

            currentSongs = self.songs
            
            if self.songs.count == 0 {
                self.tableView.hidden = true
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 2)
        
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 2)
        })
    }

    func userAddedNewSong(song: Song) {
        self.songs.append(song)
        player.insertItem(AVPlayerItem(URL: NSURL(string: song.previewUrl)), afterItem: nil)
        currentSongs = self.songs
        self.tableView.hidden = false

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPlayer" {
            if let playerController = segue.destinationViewController as? PlayerViewController {
                let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
                playerController.songs = self.songs
                playerController.index = indexPath.row
            }
        } else if segue.identifier == "goToSearch" {
            if let searchVC: SearchViewController = segue.destinationViewController as? SearchViewController {
                searchVC.delegate = self
            }
        } else if segue.identifier == "toPlayerWithButton" {
            if let playerController = segue.destinationViewController as? PlayerViewController {
                playerController.songs = currentSongs
                playerController.index = currentIndex
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}

