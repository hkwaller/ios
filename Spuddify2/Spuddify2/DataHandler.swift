//
//  DataHandler.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-12-01.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import Foundation
import CoreData

class DataHandler {
    var songs: [Song] = []
    
    init() {
        
    }
    
    func getCoreData(appDel: AppDelegate) -> [Song] {
        
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
            //self.delegate?.coreResults(self.songs)
        } else {
            println("no results")
        }
        return self.songs
    }
    
    func getJSON(searchTerm: String) -> [Song] {
        self.songs = []
        let baseURL = NSURL(string: "https://api.spotify.com/v1/search?q=\(searchTerm)&type=track")
        
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

                })
            }
        })
        downloadTask.resume()
        
        return self.songs
        
    }
}