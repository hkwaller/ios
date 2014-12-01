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
    
    func getCoreData(appDel: AppDelegate) {
        var context:NSManagedObjectContext = appDel.managedObjectContext!
        var request = NSFetchRequest(entityName: "Songs")
        request.returnsObjectsAsFaults = false
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
            println("no results bitch")
        }
    }
    
}