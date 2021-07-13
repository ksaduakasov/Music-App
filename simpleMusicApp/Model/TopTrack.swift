//
//  Top Tracks.swift
//  simpleMusicApp
//
//  Created by Kalbek Saduakassov on 22.02.2021.
//

import Foundation

class Tracks: NSObject {
    var headerTitle:String?
    var tracks:[TopTrack]?
    
    public override init() {
        
    }
    
    public init(_ headerTitle: String, _ tracks: [TopTrack]) {
        self.headerTitle = headerTitle
        self.tracks = tracks
    }
}

class TopTrack: NSObject{
    var previewURL:String?
    var artWork:String?
    var trackName:String?
    var artistName:String?
}
