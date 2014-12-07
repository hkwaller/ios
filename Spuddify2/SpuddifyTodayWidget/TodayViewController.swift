//
//  TodayViewController.swift
//  SpuddifyWidget
//
//  Created by Hannes Waller on 2014-12-02.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//
//  Today extension som viser siste spilte sang i notification center
//  Lastes in fra userDefaults å oppdateres ved hjelp av en observer etter ny sang er spilt
//

import UIKit
import NotificationCenter


class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var artist: UILabel!
    @IBOutlet weak var album: UILabel!
    @IBOutlet weak var songTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "update", name: NSUserDefaultsDidChangeNotification, object: nil)
        
        self.preferredContentSize = CGSizeMake(320, 150)
        
    }
    
    
    func update() {
        // Henter userDefaults fra hovedappen
        var defaults: NSUserDefaults = NSUserDefaults(suiteName: "group.Westerdals.SpuddifySharingDefaults")!
        var title: String = defaults.stringForKey("title")!
        var artist: String = defaults.stringForKey("artist")!
        var album: String = defaults.stringForKey("album")!
        
        self.artist.text = artist
        self.songTitle.text = title
        self.album.text = album
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        completionHandler(NCUpdateResult.NewData)
    }
    
}
