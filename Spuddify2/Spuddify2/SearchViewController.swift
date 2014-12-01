
//
//  SearchViewController.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-11-29.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import UIKit
import CoreData
import QuartzCore

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var songs: [Song] = []

    @IBOutlet weak var searchText: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchInfo: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var nib = UINib(nibName: "PlayCellTableViewCell", bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: "customCell")
        
        if songs.count == 0 {
            tableView.hidden = true
        }
    }

    @IBAction func search(sender: AnyObject) {

        
        let loadingView = getLoadingView()
        view.addSubview(loadingView)
        self.searchInfo.hidden = true
        self.songs = []
        self.tableView.reloadData()
        var track:String = searchText.text
        self.searchText.endEditing(true)

        track = track.stringByReplacingOccurrencesOfString(" ", withString: "%20", options: NSStringCompareOptions.LiteralSearch, range: nil)
        
        let baseURL = NSURL(string: "https://api.spotify.com/v1/search?q=\(track)&type=track")
        
        let sharedSession = NSURLSession.sharedSession()
        
        let downloadTask: NSURLSessionDownloadTask = sharedSession.downloadTaskWithURL(baseURL!, completionHandler: { (location:NSURL!, response:NSURLResponse!, error:NSError!) -> Void in
            
            if error == nil {
                let dataObject = NSData(contentsOfURL: location)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    let json = JSON(data: dataObject!)
                    let arr = json["tracks"]["items"]
                    
                    for (key: String, subJson: JSON) in arr {
                        let artist = subJson["artists"][0]["name"].stringValue
                        let track = subJson["name"].stringValue
                        let album = subJson["album"]["name"].stringValue
                        let img = subJson["album"]["images"][2]["url"].stringValue
                        let bigImg = subJson["album"]["images"][0]["url"].stringValue
                        let previewUrl = subJson["preview_url"].stringValue
                        self.songs.append(Song(artist: artist, title: track, album: album, imgUrl: img, previewUrl: previewUrl, bigUrl: bigImg))
                    }
                    
                    self.tableView.hidden = false;
                    self.tableView.reloadData()
                    loadingView.removeFromSuperview()
                })
            }
        })
        
        
        downloadTask.resume()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell:PlayCellTableViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as PlayCellTableViewCell
        
        var song = songs[indexPath.row]
        
        cell.loadItem(s: song)
        
        return cell
    }
    
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
        

    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.layer.transform = CATransform3DMakeScale(0.1, 0.1, 2)
        
        UIView.animateWithDuration(0.3, animations: {
            cell.layer.transform = CATransform3DMakeScale(1, 1, 2)
        })
    }

    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true;
    }
    
    func getLoadingView() -> UIView {

        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let loadingView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        
        loadingView.backgroundColor = UIColor(red: 189/255.0, green: 195/255.0, blue: 199/255.0, alpha: 0.7)
        
        var label = UILabel(frame: CGRectMake(0, 0, screenSize.width, screenSize.height))
        
        label.center = CGPointMake(screenSize.width / 2, screenSize.height / 2)
        label.textAlignment = NSTextAlignment.Center
        label.text = "Loading up some stuff for you bro!"
        
        loadingView.addSubview(label)
        
        return loadingView
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