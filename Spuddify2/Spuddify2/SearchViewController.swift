
//
//  SearchViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-29.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//
//  Tar seg av søkefunksjonaliteten i appen, presenterer resultater på søk og lar brukeren
//  legge til sanger i playlisten
//

import UIKit
import CoreData
import QuartzCore
import AVFoundation

// delegate to send new songs to playlist
protocol ShareDataDelegate {
    func userAddedNewSong(song: Song)
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var songs: [Song] = []
    var delegate: ShareDataDelegate? = nil
    var dataHandler: DataHandler = DataHandler()
    var imageCache = [String : UIImage]()
    
    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var nib = UINib(nibName: "PlayCellTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        navigationItem.title = "Search"
        
        self.searchText.delegate = self;

        if songs.count == 0 {
            tableView.hidden = true
        }
    }
    
    // Search function that checks whether or not the app har connectivity, if yes then it requests the data from the datahandler
    // and displays it.

    @IBAction func search(sender: AnyObject) {
        
        if Reachability.isConnectedToNetwork() {
            var track: String = self.searchText.text
            self.songs = []
            if (countElements(track) == 0) {
                let alert = SCLAlertView()
                alert.showError("No input", subTitle: "Unfortunately we can't search for nothing. Sorry about that.", closeButtonTitle: "OK", duration: 3.0)
                return
            }
            
            let loadingView = getLoadingView()
            view.addSubview(loadingView)
            self.searchInfo.hidden = true
            self.tableView.reloadData()
            
            self.searchText.endEditing(true)
            
            track = track.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

            dataHandler.fetchJSON(track, completion: { (data, error) -> () in
                dispatch_async(dispatch_get_main_queue()) {
                    if data!.count == 0 {
                        let alert = SCLAlertView()
                        alert.showInfo("No results", subTitle: "We didn't find any results for \"\(self.searchText.text)\", try again", closeButtonTitle: "OK", duration: 3.0)
                    } else {
                        self.navigationItem.title = "\(data!.count) results"
                        self.songs = data!
                        self.tableView.hidden = false;
                        self.tableView.reloadData()
                    }
                    loadingView.removeFromSuperview()
                }
            })
        } else {
            let alert = SCLAlertView()
            alert.showWarning("No internet connection", subTitle: "Please connect to the internet", closeButtonTitle: "OK", duration: 3.0)
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count;
    }
    
    
    // Loading up each cell in the search results with caching on the images to make it more smooth
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PlayCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as PlayCellTableViewCell
        
        var song = songs[indexPath.row]
        
        TypeOfRightButton.Search
        cell.loadItem(s: song, type: .Search)

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
    
    // Adding selected songs to core data and setting the new song on the delegate so it shows up on the playlist
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let appDel:AppDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let context:NSManagedObjectContext = appDel.managedObjectContext!
        
        var newSong = NSEntityDescription.insertNewObjectForEntityForName("Songs", inManagedObjectContext: context) as NSManagedObject
        var song = songs[indexPath.row]
        
        newSong.setValue(song.artist, forKey: "artist")
        newSong.setValue(song.title, forKey: "song")
        newSong.setValue(song.imgUrl, forKey: "imgUrl")
        newSong.setValue(song.album, forKey: "album")
        newSong.setValue(song.previewUrl, forKey: "previewUrl")
        newSong.setValue(song.bigUrl, forKey: "bigUrl")
        
        context.save(nil)
        
        let alert = SCLAlertView()
        alert.showInfo("Song added", subTitle: "\(song.title) was added to your playlist")
        
        if delegate != nil {
            let newSong: Song = song
            delegate!.userAddedNewSong(newSong)
            self.navigationController?.popToRootViewControllerAnimated(true)
        }

    }
    
    // Animations for the cells that shows up when results are presented and the table is scrolled
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 2)
        
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 2)
        })
    }
    
    // Binding up the return key to the search funciton and hiding the keyboard
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        search(self)
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true;
    }
    
    // Loading view to prevent user from fooling around with the view while the app is getting
    // the data from the API
    func getLoadingView() -> UIView {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        
        loadingView.backgroundColor = UIColor(red: 189/255.0, green: 195/255.0, blue: 199/255.0, alpha: 0.9)
        
        let label = UILabel(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        
        label.center = CGPointMake(screenSize.width / 2, screenSize.height / 2)
        label.textAlignment = NSTextAlignment.Center
        label.textColor = UIColor.whiteColor()
        label.text = "Loading some stuff for you, hang tight!"
        
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicator.center = CGPointMake(screenSize.width / 2, screenSize.height / 2 - 50)
        activityIndicator.startAnimating()
        
        loadingView.addSubview(activityIndicator)
        
        label.layer.transform = CATransform3DMakeScale(0.1, 0.1, 2)
        
        UIView.animateWithDuration(0.3, animations: {
            label.layer.transform = CATransform3DMakeScale(1, 1, 2)
        })
        
        loadingView.addSubview(label)
        
        return loadingView
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
