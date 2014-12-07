//
//  ViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-24.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//
//  Her vises spillelisten. Mulighet for å slette sanger, samt gå til søk eller avspilling
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
        
    }
    
    // Tar vekk observer når viewen forsvinner slik at det ikke blir dobbelt
    override func viewDidDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // Legger til observer og sjekker hvis knappen til player skal være aktiv, i tillegg blir nåværende celle
    // markert i forhold til hvilken sang som spilles
    override func viewWillAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRow", name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
        
        if player.active {
            barButtonPlayer.enabled = true
        } else {
            barButtonPlayer.enabled = false
        }
        updateRow()
    }
    
    // Funksjon som følger med på hvilken cell som skal markeres
    func updateRow() {
        var index: NSIndexPath = NSIndexPath(forRow: player.getCurrentIndex(), inSection: 0)
        self.tableView.selectRowAtIndexPath(index, animated: true, scrollPosition: UITableViewScrollPosition.None)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count;
    }
    
    // Populerer celler med samme chaching av bilder som på search viewet
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
    
    
    // Prøver å spille av cellen som blir tappet, med en sjekk for at internet er tilgjengelig
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if Reachability.isConnectedToNetwork() {
            self.performSegueWithIdentifier("goToPlayer", sender:self)
        } else {
            let alert = SCLAlertView()
            alert.showWarning("No internet connection", subTitle: "Please connect to the internet", closeButtonTitle: "OK", duration: 3.0)
        }
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // Når brukeren tar bort en celle kjøres denne funksjonen som tar bort sangen fra core og fra spilleren hvis den
    // er startet
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            dataHandler.deleteSongFromCore(self.songs[indexPath.row])
            println(player)
            
            if player.player.currentItem != nil {
                player.deleteSong(indexPath.row)
            }

            self.songs.removeAtIndex(indexPath.row)
            
            if indexPath.row - 1 == player.getCurrentIndex() {
                self.barButtonPlayer.enabled = false
            }
            
            updateRow()
            
            if self.songs.count == 0 {
                
                UIView.animateWithDuration(0.5, delay: 0.0, options: nil, animations: { () -> Void in

                    self.tableView.layer.transform = CATransform3DMakeTranslation(-1000.0, 0, 0)
                    }, completion: { (value: Bool) -> Void in
                    self.tableView.layer.transform = CATransform3DMakeTranslation(0, 0, 0)
                    self.tableView.hidden = true
                    player.pause()
                    self.barButtonPlayer.enabled = false
                })
                
            }
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    // Animasjon på cellene, samme som i search view
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 2)
        
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 2)
        })
    }

    // Delegate metoden for å legge til sanger
    func userAddedNewSong(song: Song) {
        self.songs.append(song)
        if player.active {
            player.addedSong(song)
        }
        self.tableView.hidden = false

    }
    
    // Funksjonalitet for de ulike seguesene
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
                playerController.index = player.getCurrentIndex()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    



}

