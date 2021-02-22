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
}

class TopTrack: NSObject{
    var previewURL:String?
    var artWork:String?
    var trackName:String?
    var artistName:String?
}
