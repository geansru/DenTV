//
//  PlaylistsViewController.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData

class PlaylistsViewController: UIViewController {
    
    // MARK: - Properties
    var dataTask: NSURLSessionDataTask? // Downloadable
    var source = Source.AllPlaylists // Downloadable
    var managedContext: NSManagedObjectContext! // Downloadable
    var data: NSData?
    var list: [Playlist] = []
    var predicate: NSPredicate!
    // MARK: - IBOutlet's
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func search(sender: AnyObject) {
        let alert = UIAlertController(title: "Поиск", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        let searchTitle = "Искать"
        let clearTitle = "Очистить"
        let cancelTitle = "Отмена"
        let closure: ((UIAlertAction) -> Void)? = { (action: UIAlertAction) -> Void in
            let tf = alert.textFields![0]
            switch action.title! {
            case searchTitle:
                Log.m("search action")
                guard let text = tf.text else { return }
                if text.isEmpty { return }
                self.predicate = NSPredicate(format: "name CONTAINS[cd] %@", text)
                self.list = self.getFromStorage()
                self.tableView.reloadData()
            case clearTitle:
                Log.m("clear action")
                self.predicate = nil
                self.list = self.getFromStorage()
                self.tableView.reloadData()
            default: break
            }
        }
        alert.addTextFieldWithConfigurationHandler { (field:UITextField) -> Void in
            field.placeholder = "Введите строку для поиска"
        }
        
        let search = UIAlertAction(title: searchTitle, style: UIAlertActionStyle.Default, handler: closure)
        let clear = UIAlertAction(title: clearTitle, style: UIAlertActionStyle.Default, handler: closure)
        let cancel = UIAlertAction(title: cancelTitle, style: UIAlertActionStyle.Cancel, handler: closure)
        alert.addAction(search)
        alert.addAction(clear)
        alert.addAction(cancel)
        presentViewController(alert, animated: true, completion: nil)
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setNeedsStatusBarAppearanceUpdate()
        Staff.registerCell(TableViewCellIdentifiers.PlaylistCell, tableView: tableView)
        tableView.rowHeight = 200
        list = getFromStorage()
        if list.isEmpty { refresh() }
        tableView.reloadData()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! PlaylistItemsViewController
        controller.managedContext = managedContext
        let uid = list[sender as! Int].uid!
        controller.source = Source.Playlist(uid: uid)
    }
}

extension PlaylistsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.PlaylistCell, forIndexPath: indexPath) as! PlaylistCell
        cell.configureUI(list[indexPath.row])
//        configureCell(cell, indexPath: indexPath)
        return cell
    }
    
    private func configureCell(cell: UITableViewCell, indexPath: NSIndexPath) {
        let object = list[indexPath.row]
        cell.textLabel?.text = "\(indexPath.row). " + object.name!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showVideo", sender: indexPath.row)
    }
}

extension PlaylistsViewController {
    // MARK: Helper
    func refresh() {
        let _ = Content(object: self, delegate: self)
    }
    
    func getFromStorage() -> [Playlist] {
        var list = [Playlist]()
        let request = NSFetchRequest(entityName: "Playlist")
        if let _ = predicate { request.predicate = predicate! }
        if let aux = try? managedContext.executeFetchRequest(request) {
            if let result = aux as? [Playlist]{
                list = result
            }
        }
        return list
    }
}

extension PlaylistsViewController: ParserDelegate {
    // MARK: ParserDelegate
    func parserDidReceiveError(parser: Parser, error: String) {
        Log.m(error, level: LogLevel.ERROR)
    }
    func parserWillStartParse(parser: Parser) {
        Log.m(__FUNCTION__)
    }
    func parserDidFinishParse(parser: Parser, result: [AnyObject]) {
        if let _ = result as? [Playlist] {
            list = result as! [Playlist]
            tableView.reloadData()
            if managedContext.hasChanges {
                let _ = try? managedContext.save()
            }
            Log.m("result is type of [Playlist]. Count \(list.count)")
        } else {
            Log.m("result is NOT type of [Playlist]")
        }
        Log.m(__FUNCTION__)
    }
}

extension PlaylistsViewController:  Parseable {}

extension PlaylistsViewController: Downloadable {
    func getURL() -> NSURL? {
        return source.entityValue
    }
}

extension PlaylistsViewController: ContentDelegate {
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