//
//  TodayViewController.swift
//  SpuddifyWidget
//
//  Created by Hannes Waller on 2014-12-02.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//
//  Today extension som viser siste spilte sang i notification center
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
        // Dispose of any resources that can be recreated.
    }
    
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.NewData)
    }
    
}
