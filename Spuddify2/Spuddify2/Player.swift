//
//  Player.swift
//  Spuddify2
//
//  Created by Hannes Waller on 2014-12-07.
//  Copyright (c) 2014 Hannes Waller. All rights reserved.
//
//  Player klasse for å få til funksjonalitet som ikke finnes i AVQueuePlayer fra starten av
//
//

import Foundation
import AVFoundation

class Player : AVQueuePlayer {
    var player: AVQueuePlayer = AVQueuePlayer()
    var currentIndex: Int = 0
    var songs: [Song]!
    var allItems: [AVPlayerItem] = [AVPlayerItem]()
    var currentItems: [AVPlayerItem] = [AVPlayerItem]()
    
    var playing: Bool {
        if self.player.rate > 0.1 {
            return true
        }
        return false
    }
    
    var active: Bool {
        if self.player.currentItem != nil {
            return true
        } else {
            return false
        }
    }
    
    override init() {
        super.init()
        self.currentIndex = 0
    }
    
    
    /*
     *  CONTROLLER METHODS
     */
    
    func loadSongs(songs: [Song], index: Int) {
        self.currentItems = []
        self.songs = songs
        self.currentIndex = index
        
        for var i = index; i < self.songs.count; i++ {
            var str = self.songs[i].previewUrl
            var url = NSURL(string: str)!
            self.currentItems.append(AVPlayerItem(URL: url))
        }
        
        self.player = AVQueuePlayer(items: self.currentItems)
        self.player.play()
        
        loadAllItems()
    }
    
    func nextSong() {
        if self.currentIndex + 1 == self.songs.count { return }
        self.player.advanceToNextItem()
        self.currentIndex++
    }
    
    func previousSong() {
        if self.currentIndex - 1 < 0 { return }
        
        self.currentIndex--
        self.currentItems = []
        
        for var i = self.currentIndex; i < self.songs.count; i++ {
            var str = self.songs[i].previewUrl
            self.currentItems.append(AVPlayerItem(URL: NSURL(string: str)))
        }
        
        self.player = AVQueuePlayer(items: currentItems)
        self.player.play()
    }
    
    func togglePlayer() {
        if self.playing {
            self.player.pause()
        } else {
            self.player.play()
        }
    }
    
    /*
     * GETTERS
     */
    
    func getCurrentItem() -> AVPlayerItem {
        return self.player.currentItem!
    }
    
    func getCurrentSongs() -> [Song] {
        return self.songs
    }
    
    func isPlaying() -> Bool {
        return self.playing
    }
    
    func getCurrentSong() -> Song {
        return self.songs[currentIndex]
    }
    
    func getCurrentIndex() -> Int {
        return self.currentIndex
    }
    
    /*
     * PLAYLIST METHODS
     */
    
    func loadAllItems() {
        self.allItems = []
        
        for var i = 0; i < self.songs.count; i++ {
            var str = self.songs[i].previewUrl
            self.allItems.append(AVPlayerItem(URL: NSURL(string: str)))
        }
    }
    
    func deleteSong(index: Int!) {
        
        var tempSong = self.songs[index] as Song
        var tempURL = NSURL(string: tempSong.previewUrl)
        
        for var i = 0; i < self.currentItems.count; i++ {
            var asset: AVAsset = self.currentItems[i].asset
            var urlAsset = asset as AVURLAsset
            if tempURL == urlAsset.URL {
                player.removeItem(self.currentItems[i] as AVPlayerItem)
            }
        }
        
        if index == self.currentIndex {
            self.currentItems = []
            for var i = self.currentIndex; i < self.songs.count; i++ {
                var str = self.songs[i].previewUrl
                self.currentItems.append(AVPlayerItem(URL: NSURL(string: str)))
            }
            player = AVQueuePlayer(items: items())
        } else if index < self.currentIndex {
            self.currentIndex--
        }
        
        self.songs.removeAtIndex(index)
        self.allItems.removeAtIndex(index)
        
        if self.currentIndex == self.songs.count {
            self.currentIndex--
        }
    }
    
    func addedSong(song: Song) {
        var tempURL = NSURL(string: song.previewUrl)
        var item = AVPlayerItem(URL: tempURL)
        
        self.player.insertItem(item, afterItem: nil)
        
        self.songs.append(song)
        self.currentItems.append(item)
        self.allItems.append(item)
    }
}
