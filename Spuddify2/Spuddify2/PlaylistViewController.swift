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
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        self.songs = dataHandler.getCoreData(appDel)
        
        if songs.count == 0 { self.tableView.hidden = true }

        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Getting songs again")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        searchButton.layer.cornerRadius = 30;
        
        var nib = UINib(nibName: "PlayCellTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("goToPlayer", sender:self)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            dataHandler.deleteSongFromCore(self.songs[indexPath.row])

            self.songs.removeAtIndex(indexPath.row)
            
            if self.songs.count == 0 {
                self.tableView.hidden = true
            }
            
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
        self.songs = self.dataHandler.getCoreData(self.appDel)
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

