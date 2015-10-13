//
//  FavouriteVideoListViewController.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData

class FavouriteVideoListViewController: UIViewController {
    
    // MARK: - Properties
    var managedContext: NSManagedObjectContext!
    var list: [Video] = []
    var predicate: NSPredicate!
    // MARK: - @IBAction

    // MARK: - @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        refresh()
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let nav = segue.destinationViewController as! UINavigationController
//        let controller = nav.topViewController as! VideoDetailsViewController
        let controller = segue.destinationViewController as! VideoDetailsViewController
        controller.video = list[sender as! Int]
        controller.managedContext = managedContext
    }
    
    // MARK: Helper
    func refresh() {
        list = getFromStorage()
        if list.count > 0 { tableView.reloadData() }
    }
    func configureUI() {
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.rowHeight = 245
        Staff.registerCell(TableViewCellIdentifiers.VideoCell, tableView: tableView)
    }
    
    func getFromStorage() -> [Video] {
        let request = NSFetchRequest(entityName: "Video")
        request.predicate = NSPredicate(format: "isFavourite = YES")
        if let aux = try? managedContext.executeFetchRequest(request) {
            if let result = aux as? [Video]{
                Log.m(__FUNCTION__)
                Log.m("results.count: \(result.count)")
                return result
            }
        }
        return [Video]()
    }

}

extension FavouriteVideoListViewController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource, UITableViewDelegate
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            TableViewCellIdentifiers.VideoCell, forIndexPath: indexPath) as! VideoCell
        let video = list[indexPath.row]
        cell.configureCell(video)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showVideo", sender: indexPath.row)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            let video = list[indexPath.row]
            video.isFavourite = NSNumber(bool: false)
            list = getFromStorage()
            tableView.reloadData()
        default: break
        }
    }
}