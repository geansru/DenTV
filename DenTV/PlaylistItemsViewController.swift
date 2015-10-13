//
//  PlaylistItemsViewController.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 13.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData

class PlaylistItemsViewController: UIViewController {

    // MARK: - @IBOulets
    @IBOutlet weak var tableView: UITableView!
    @IBAction func back(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Properties
    var managedContext:NSManagedObjectContext!
    var entity: Entity?
    var source: Source?
    var list: [Video] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        entity = Entity(closure: closure, managedContext: managedContext, source: source!)
        configureUI()
        refresh()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let controller = segue.destinationViewController as! VideoDetailsViewController
        controller.video = list[sender as! Int]
        controller.managedContext = managedContext
    }

    // MARK: - Helper
    func refresh() {
        entity?.refresh()
        tableView.reloadData()
    }
    
    func configureUI() {
        self.setNeedsStatusBarAppearanceUpdate()
        tableView.rowHeight = 245
        Staff.registerCell(TableViewCellIdentifiers.VideoCell, tableView: tableView)
    }
    
    // MARK: Closure
    
    private func closure(result: [AnyObject]) {
        if let _ = result as? [Video] {
            list = result as! [Video]
            tableView?.reloadData()
            Log.m("result is type of [Video]")
        } else {
        Log.m("result is NOT type of [Video]")
        }
        Log.m(__FUNCTION__)
    }
}

extension PlaylistItemsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.VideoCell, forIndexPath: indexPath) as! VideoCell
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
}
