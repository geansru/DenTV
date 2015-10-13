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
    var entity: Entity!
    func closure(result: [AnyObject]) {
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
    
    
    // MARK: - IBOutlet's
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        entity = Entity(closure: closure, managedContext: managedContext)
        configureUI()
//        list = getFromStorage()
        if list.isEmpty { entity.refresh() }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let nav = segue.destinationViewController as! UINavigationController
//        let controller = nav.topViewController as! VideoDetailsViewController
        let controller = segue.destinationViewController as! VideoDetailsViewController
        controller.video = list[sender as! Int]
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
    func configureUI() {
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.rowHeight = 245
        Staff.registerCell(TableViewCellIdentifiers.VideoCell, tableView: tableView)
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