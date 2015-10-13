//
//  Parser.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 12.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

enum Source {
    case Playlist(uid: String)
    case AllPlaylists
    case Video(uid: String)
    case Search
    
    var entityValue: NSURL? {
        var url: NSURL? = nil
        switch self {
        case .Search: url = NSURL(string: searchPath())
        case .AllPlaylists: url = NSURL(string: allPlaylistsPath())
        case .Playlist(let uid): url = NSURL(string: playlistPath(uid))
        case .Video(let uid): url = NSURL(string: videoPath(uid))
        }
        return url
    }
    
    var key: String { return "AIzaSyA4Ev68oKg5LeIYR12swjzSFFc9EI0mY2Q" }
    var channelId: String { return "UCZNKg6NI7mah4i3dE6m0oYw" }
    var basePath: String { return "https://www.googleapis.com/youtube/v3/" }
    var tail: String { return "order=date&maxResults=50" }
    var part: String { return "part=snippet,contentDetails,id" }
    
    private func playlistPath(uid: String) -> String {
        let path = "\(basePath)playlistItems?\(part)&playlistId=\(uid)&key=\(key)&\(tail)"
        Log.m(path)
        return path
    }
    private func searchPath() -> String {
        let path = "\(basePath)search?key=\(key)&channelId=\(channelId)&part=snippet,id&\(tail)"
        Log.m(path)
        return path
    }
    private func videoPath(uid: String) -> String {
        let path = "\(basePath)videos?id=\(uid)&key=\(key)&\(part)"
        Log.m(path)
        return path
    }
    private func allPlaylistsPath() -> String {
        let path = "\(basePath)playlists?\(part)&channelId=\(channelId)&key=\(key)&\(tail)"
        Log.m(path)
        return path
    }
}
protocol ParserDelegate {
    func parserDidReceiveError(parser: Parser, error: String)
    func parserWillStartParse(parser: Parser)
    func parserDidFinishParse(parser: Parser, result: [AnyObject])
}

protocol Parseable {
    var source: Source {get set}
    var data: NSData? { get set }
}

class Parser {
    private let queueName = "ru.1appstudio.ios.DenTV.Parser.bgqueue"
    let backgroundQueue: dispatch_queue_t!
    var delegate: ParserDelegate?
    var object: Parseable
    var context: NSManagedObjectContext {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        return appDelegate.coreDataStack.context
    }
    
    init(object: Parseable) {
        self.object = object
        backgroundQueue = dispatch_queue_create(queueName, nil)
    }
    
    convenience init(object: Parseable, delegate: ParserDelegate) {
        self.init(object: object)
        self.delegate = delegate
        parse()
    }
    
    // MARK: Main parse function
    func parse() {
        dispatch_async(backgroundQueue) {
            self.parseAsync()
        }
    }
    
    // MARK: Parse current cases
    private func parsePlaylist() -> [AnyObject] {
        var list: [Video] = []
        let data = JSON(data: object.data!)
        let items = data["items"]
        for i in 0..<items.count {
            list.append( makeVideoObjectFromPlaylist(items, i: i) )
        }
        return list
    }
    
    private func parseVideo() -> [AnyObject] {
//        let data = JSON(data: object.data!)
        // FIXME: Make parse
        return [AnyObject]()
    }
    
    private func parseSearch() -> [AnyObject] {
        var list: [Video] = []
        let data = JSON(data: object.data!)
        let items = data["items"]
        for i in 0..<items.count {
            list.append( makeVideoObject(items, i: i) )
        }
        return list
    }
    
    private func parseAllPlaylists() -> [AnyObject] {
        var list: [Playlist] = []
        let data = JSON(data: object.data!)
        let items = data["items"]
        for i in 0..<items.count {
            list.append( makePlaylistObject(items, i: i) )
        }
        return list
    }
    
    // MARK: Parse func body
    private func parseAsync() {
        dispatch_async(dispatch_get_main_queue()) {
            delegate?.parserWillStartParse(self)
        }
        var result = [AnyObject]()
        switch object.source {
        case .Playlist: result = parsePlaylist()
        case .Video: result = parseVideo()
        case .Search: result = parseSearch()
        case .AllPlaylists: result = parseAllPlaylists()
        }
        dispatch_async(dispatch_get_main_queue()) {
            delegate?.parserDidFinishParse(self, result: result)
        }
    }
    
    // MARK: Helpers
    private func makePlaylistObject(items: JSON, i: Int) -> Playlist {
        let playlist = Playlist(entity: getEntity()!, insertIntoManagedObjectContext: context)
        
        let uid = items[i]["id"].string
        playlist.uid = uid
        
        let request = NSFetchRequest(entityName: "Playlist")
        request.predicate = NSPredicate(format: "uid = %@", "uid")
        if let result = try? context.executeFetchRequest(request) {
            if !result.isEmpty {
                if let aux = result[0] as? Playlist { return aux }
            }
        }
        let name = items[i]["snippet"]["title"].string
        playlist.name = name
        
        playlist.about = ""
        
        let thumb = items[i]["snippet"]["thumbnails"]["medium"]["url"].string
        playlist.thumb = thumb
        
        debug(playlist)
        return playlist
    }
    private func makeVideoObjectFromPlaylist(items: JSON, i: Int) -> Video {
        let video = Video(entity: getEntity(Source.Search)!, insertIntoManagedObjectContext: context)
        
        let uid = items[i]["snippet"]["resourceId"]["videoId"].string
        video.uid = uid
        
        let name = items[i]["snippet"]["title"].string
        video.name = name
        
        let about = items[i]["snippet"]["description"].string
        video.about = about
        
        let thumb = items[i]["snippet"]["thumbnails"]["medium"]["url"].string
        video.thumb = thumb
        if let publishedAt = items[i]["snippet"]["publishedAt"].string {
            let published = formatDate(publishedAt)
            video.date = published
        } else {
            video.date = NSDate()
        }
        
        video.isFavourite = false
        video.isNew = true
        debug(video)
        return video
    }
    private func makeVideoObject(items: JSON, i: Int) -> Video {
        let uid = items[i]["id"]["videoId"].string
        if let video = searchForVideoObject(uid!) { return video }
        
        let video = Video(entity: getEntity()!, insertIntoManagedObjectContext: context)
        video.uid = uid
        let name = items[i]["snippet"]["title"].string
        video.name = name
        
        let about = items[i]["snippet"]["description"].string
        video.about = about
        
        let thumb = items[i]["snippet"]["thumbnails"]["medium"]["url"].string
        video.thumb = thumb
        
        if let publishedAt = items[i]["snippet"]["publishedAt"].string {
            let published = formatDate(publishedAt)
            Log.m("published: \(published)")
            video.date = published
        } else {
            video.date = NSDate()
        }
        
        video.isFavourite = false
        video.isNew = true
//        debug(video)
        return video
    }
    
    func searchForVideoObject(uid: String) -> Video? {
        let request = NSFetchRequest(entityName: "Video")
        request.predicate = NSPredicate(format: "uid = %@", uid)
        if let results = try? context.executeFetchRequest(request) {
            if results.count > 0 { return (results.first! as! Video) }
        }
        return nil
    }
    
    private func getOrCreatePlayist(uid: String) -> Playlist {
        let playlist = Playlist(entity: getEntity(Source.AllPlaylists)!, insertIntoManagedObjectContext: context)
        let request = NSFetchRequest(entityName: "Playlist")
        request.predicate = NSPredicate(format: "uid = %@", uid)
        
        if let playlists = try? context.executeFetchRequest(request) as? [Playlist] {
            if let _ = playlists where playlists?.count > 0 {
                return playlists![0]
            }
        }
        
        return playlist
    }
    
    private func getEntity(source: Source) ->  NSEntityDescription? {
        switch source {
        case .Playlist(_), .AllPlaylists:
            return NSEntityDescription.entityForName("Playlist", inManagedObjectContext: context)
        default:
            return NSEntityDescription.entityForName("Video", inManagedObjectContext: context)
        }
    }
    
    private func getEntity() ->  NSEntityDescription? {
        return getEntity(object.source)
    }
    
    private func formatDate(d: String) -> NSDate {
        let formatter = NSDateFormatter()
        formatter.dateFormat = ""
        return formatter.dateFromString(d) ?? NSDate()
    }
    
    private func debug(playlist: Playlist) {
        Log.d(
            "uid: \(playlist.uid)\n" +
                "name: \(playlist.name)\n" +
                "thumb: \(playlist.thumb)\n"
        )
    }
    
    private func debug(video: Video) {
        Log.d(
            "video.uid: \(video.uid)\n" +
            "video.name: \(video.name)\n" +
            "video.thumb: \(video.thumb)\n" +
            "video.about: \(video.about)\n" +
            "video.date: \(video.date)\n" +
            "video.playlist: \(video.playlist)\n"
        )
    }
}