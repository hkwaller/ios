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

class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var songs: [Song] = []
    var playlist: [AVPlayerItem] = []
    let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()        

        var context:NSManagedObjectContext = appDel.managedObjectContext!
        var request = NSFetchRequest(entityName: "Songs")
        request.returnsObjectsAsFaults = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        var results = context.executeFetchRequest(request, error: nil)
        
        if results?.count > 0 {
            for result: AnyObject in results! {
                //var pass = result.password!!
                if let artist = result.valueForKey("artist") as? String {
                    if let title = result.valueForKey("song") as? String {
                        if let imgUrl = result.valueForKey("imgUrl") as? String {
                            if let album = result.valueForKey("album") as? String {
                                if let bigUrl = result.valueForKey("bigUrl") as? String {
                                    if let previewUrl = result.valueForKey("previewUrl") as? String {
                                        songs.append(Song(artist: artist, title: title, album: album, imgUrl: imgUrl, previewUrl: previewUrl, bigUrl: bigUrl))
                                        //playlist.append(AVPlayerItem(URL: NSURL(string: previewUrl)!))
                                    }
                                }
                            }
                        }
                    }
                }
            }
        } else {
            println("no results bitch")
        }
        
        if songs.count == 0 { self.tableView.hidden = true }

        
        searchButton.layer.cornerRadius = 30;
        
        var nib = UINib(nibName: "PlayCellTableViewCell", bundle: nil)
        
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        //tableView.backgroundColor = UIColor(red: 255.0/255.0, green: 40/255.0, blue: 81/255.0, alpha: 1.0)

    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PlayCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as PlayCellTableViewCell
        
        let song = songs[indexPath.row]
        
        cell.loadItem(s: song)
        
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPlayer" {
            let playerController = segue.destinationViewController as PlayerViewController
            let indexPath:NSIndexPath = self.tableView.indexPathForSelectedRow()!
            
            playerController.songs = self.songs
            playerController.index = indexPath.row
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

