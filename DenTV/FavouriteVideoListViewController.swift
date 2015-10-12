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

    // MARK: - @IBAction
    @IBAction func search(sender: AnyObject) {
    }
    // MARK: - @IBOutlet
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        list = getFromStorage()
        if list.count > 0 {
            tableView.reloadData()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let nav = segue.destinationViewController as! UINavigationController
        let controller = nav.topViewController as! VideoDetailsViewController
        controller.managedContext = self.managedContext
        let video = list[sender as! Int]
        controller.video = video
    }
    
    // MARK: Helper
    
    func getFromStorage() -> [Video] {
        let request = NSFetchRequest(entityName: "Video")
        request.predicate = NSPredicate(format: "isFavourite = %@", true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        cell.textLabel?.text = list[indexPath.row].name
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("showVideo", sender: indexPath.row)
    }
}