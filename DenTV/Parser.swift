//
//  Parser.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 12.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation

enum Source {
    case Playlist
    case Video
    case Search
}
protocol ParserDelegate {
    func parserDidReceiveError(parser: Parser, error: String)
    func parserWillStartParse(parser: Parser)
    func parserDidFinishParse(parser: Parser, result: [AnyObject])
}

protocol Parseable {
    func getType() -> Source
    func getData() -> NSData
}

class Parser {
    var delegate: ParserDelegate?
    var object: Parseable
    
    init(object: Parseable) {
        self.object = object
    }
    
    convenience init(object: Parseable, delegate: ParserDelegate) {
        self.init(object: object)
        self.delegate = delegate
        parse()
    }
    
    private func parsePlaylist() -> [AnyObject] {
        // FIXME: Make parse
        return [AnyObject]()
    }
    
    private func parseVideo() -> [AnyObject] {
        // FIXME: Make parse
        return [AnyObject]()
    }
    
    private func parseSearch() -> [AnyObject] {
        // FIXME: Make parse
        return [AnyObject]()
    }
    
    func parse() {
        delegate?.parserWillStartParse(self)
        var result = [AnyObject]()
        switch object.getType() {
        case .Playlist: result = parsePlaylist()
        case .Video: result = parseVideo()
        case .Search: result = parseSearch()
        }
        delegate?.parserDidFinishParse(self, result: result)
    }
    
}