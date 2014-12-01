//
//  DataHandler.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-12-01.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//

import Foundation

protocol DataHandlerDelegate {
    func apiResults(results: NSDictionary)
    func coreResults(results: NSDictionary)
}

class DataHandler {
    
    var delegate: DataHandlerDelegate?
    
    init() {
        
    }
    
    func searchItunesFor(searchTerm: String) {
        
        // The iTunes API wants multiple terms separated by + symbols, so replace spaces with + signs
        let itunesSearchTerm = searchTerm.stringByReplacingOccurrencesOfString(" ", withString: "+", options: NSStringCompareOptions.CaseInsensitiveSearch, range: nil)
        
        // Now escape anything else that isn't URL-friendly
        if let escapedSearchTerm = itunesSearchTerm.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding) {
            let urlPath = "http://itunes.apple.com/search?term=\(escapedSearchTerm)&media=software"
            let url: NSURL = NSURL(string: urlPath)!
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url, completionHandler: {data, response, error -> Void in
                println("Task completed")
                if(error != nil) {
                    // If there is an error in the web request, print it to the console
                    println(error.localizedDescription)
                }
                var err: NSError?
                
                var jsonResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error: &err) as NSDictionary
                if(err != nil) {
                    // If there is an error parsing JSON, print it to the console
                    println("JSON Error \(err!.localizedDescription)")
                }
                let results: NSArray = jsonResult["results"] as NSArray
                
                self.delegate?.apiResults(jsonResult)
            })
            
            task.resume()
        }
    }
    
    func getCoreData() {
    
    }
    
}