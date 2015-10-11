//
//  Video.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

class Video {
    var uid = ""
    var name = ""
    var about = ""
    var thumb = ""
    weak var playlist: Playlist?
}


class Playlist {
    var uid = ""
    var name = ""
    var about = ""
    var thumb = ""
    var videos: [Video] = []
}