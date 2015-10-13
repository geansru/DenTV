//
//  Entity.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 13.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import Foundation
import CoreData
class Entity {
    // MARK: - Properties
    var dataTask: NSURLSessionDataTask? // Downloadable
    var source = Source.Search // Downloadable
    var managedContext: NSManagedObjectContext! // Downloadable
    var data: NSData?
    var closure: ([AnyObject])->()
    
    init(closure: ([AnyObject])->(), managedContext: NSManagedObjectContext) {
        self.closure = closure
        self.managedContext = managedContext
    }
    
    convenience init(closure: ([AnyObject])->(), managedContext: NSManagedObjectContext, source: Source) {
        self.init(closure: closure, managedContext: managedContext)
        self.source = source
    }
}

extension Entity {
    // MARK: Helper
    func refresh() {
        let _ = Content(object: self, delegate: self)
    }
    
    func getFromStorage() -> [Video] {
        var list = [Video]()
        let request = NSFetchRequest(entityName: "Video")
        if let aux = try? managedContext.executeFetchRequest(request) {
            if let result = aux as? [Video]{
                list = result
            }
        }
        return list
    }
}

extension Entity: ParserDelegate {
    // MARK: ParserDelegate
    func parserDidReceiveError(parser: Parser, error: String) {
        Log.m(error, level: LogLevel.ERROR)
    }
    func parserWillStartParse(parser: Parser) {
        Log.m(__FUNCTION__)
    }
    func parserDidFinishParse(parser: Parser, result: [AnyObject]) {
        closure(result)
    }
}

extension Entity:  Parseable {}

extension Entity: Downloadable {
    func getURL() -> NSURL? {
        return source.entityValue
    }
}

extension Entity: ContentDelegate {
    // MARK: - ContentDelegate
    func contentDownloaderDidReceiveError(content: Content, status: State, error: NSError?) {
        Log.m(status.entityValue)
        if let _ = error { Log.e(error!) }
        
    }
    func contentDownloaderDidReceiveResponse(content: Content, response: NSHTTPURLResponse) {
        let mess: String = "Received status code: \(response.statusCode)"
        Log.m(mess)
    }
    func contentDownloaderWillStart(content: Content, status: State) {
        Log.m(status.entityValue)
    }
    func contentDownloaderDidFinishWithNotFound(content: Content, status: State) {
        Log.m(status.entityValue)
    }
    func contentDownloaderDidFinishWithResult(content: Content, status: State, result: NSData) {
        self.data = result
        let _ = Parser(object: self, delegate: self)
        Log.m(status.entityValue)
    }
}