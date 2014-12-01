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
    var playlist: [AVPlayerItem] = []
    let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]
        
        self.songs = getCoreData()
        
        if songs.count == 0 { self.tableView.hidden = true }

        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Getting songs again")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        searchButton.layer.cornerRadius = 30;
        
        var nib = UINib(nibName: "PlayCellTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
    }
    
    func getCoreData() -> [Song] {
        var request = NSFetchRequest(entityName: "Songs")
        request.returnsObjectsAsFaults = false
        var context:NSManagedObjectContext = appDel.managedObjectContext!

        var results = context.executeFetchRequest(request, error: nil)
        
        if results?.count > 0 {
            for result: AnyObject in results! {
                if let artist = result.valueForKey("artist") as? String {
                    if let title = result.valueForKey("song") as? String {
                        if let imgUrl = result.valueForKey("imgUrl") as? String {
                            if let album = result.valueForKey("album") as? String {
                                if let bigUrl = result.valueForKey("bigUrl") as? String {
                                    if let previewUrl = result.valueForKey("previewUrl") as? String {
                                        self.songs.append(Song(artist: artist, title: title, album: album, imgUrl: imgUrl, previewUrl: previewUrl, bigUrl: bigUrl))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            println("no results")
        }
        return self.songs
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PlayCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as PlayCellTableViewCell
        let song = songs[indexPath.row]
        
        cell.loadItem(s: song, type: .Playlist)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("goToPlayer", sender:self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            songs.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            var context:NSManagedObjectContext = appDel.managedObjectContext!
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 2)
        
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 2)
        })
    }
    
    func refresh(sender:AnyObject) {
        self.songs = []
        self.songs = getCoreData()
        self.refreshControl.endRefreshing()
    }
    
    func userAddedNewSong(song: Song) {
        self.songs.append(song)
        self.tableView.hidden = false

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPlayer" {
            let playerController = segue.destinationViewController as PlayerViewController
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            playerController.songs = self.songs
            playerController.index = indexPath.row
        } else if segue.identifier == "goToSearch" {
            let searchVC: SearchViewController = segue.destinationViewController as SearchViewController
            searchVC.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

