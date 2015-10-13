//
//  HomeViewController.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData

class HomeViewController: UIViewController {
    
    // MARK: - Properties
    var dataTask: NSURLSessionDataTask? // Downloadable
    var source = Source.Search // Downloadable
    var managedContext: NSManagedObjectContext! // Downloadable
    var data: NSData?
    var list: [Video] = []
    
    // MARK: - IBOutlet's
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.rowHeight = 245
        Staff.registerCell(TableViewCellIdentifiers.VideoCell, tableView: tableView)
        list = getFromStorage()
        if list.isEmpty { refresh() }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nav = segue.destinationViewController as! UINavigationController
        let controller = nav.topViewController as! VideoDetailsViewController
        let video = list[sender as! Int]
        controller.video = video
        controller.managedContext = managedContext
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.VideoCell, forIndexPath: indexPath) as! VideoCell
        let video = list[indexPath.row]
        cell.configureCell(video)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showVideo", sender: indexPath.row)
    }
    
    private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        
        let video = list[indexPath.row]
        let url = NSURL(string: video.uid!)!
        cell.imageView?.loadImageWithURL(url)
        cell.textLabel?.text = video.name
        cell.detailTextLabel?.text = video.about
    }
}

extension HomeViewController: UISearchBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.TopAttached
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
}

extension HomeViewController {
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

extension HomeViewController: ParserDelegate {
    // MARK: ParserDelegate
    func parserDidReceiveError(parser: Parser, error: String) {
        Log.m(error, level: LogLevel.ERROR)
    }
    func parserWillStartParse(parser: Parser) {
        Log.m(__FUNCTION__)
    }
    func parserDidFinishParse(parser: Parser, result: [AnyObject]) {
        if let _ = result as? [Video] {
            list = result as! [Video]
            tableView.reloadData()
            let _ = try? managedContext.save()
            Log.m("result is type of [Video]")
        } else {
            Log.m("result is NOT type of [Video]")
        }
        Log.m(__FUNCTION__)
    }
}

extension HomeViewController:  Parseable {}

extension HomeViewController: Downloadable {
    func getURL() -> NSURL? {
        return source.entityValue
    }
}

extension HomeViewController: ContentDelegate {
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