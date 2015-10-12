//
//  VideoDetailsViewController.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 12.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData

class VideoDetailsViewController: UITableViewController {

    // MARK: - @IBAction
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    @IBAction func save(sender: AnyObject) {
        let liked = !video.isFavourite!.boolValue
        video.isFavourite = NSNumber(bool: liked)
        let _ = try? managedContext.save()
    }
    // MARK: - @IBOutlets
    
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var publishedLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    // MARK: - Properties
    var video: Video! {
        didSet {
            if isViewLoaded() {
                updateUI()
            }
        }
    }
    var managedContext: NSManagedObjectContext!
   
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        video.isNew = NSNumber(bool: false)
        updateUI()
    }
 
    // MARK: - TableView
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch (indexPath.section, indexPath.row) {
        case (1, 1):
            let url = NSURL(string: "http://www.youtube.com/watch?v=\(video.uid!)")
            UIApplication.sharedApplication().openURL(url!)
        default: break
        }
    }
    
}


extension VideoDetailsViewController {
    // MARK: Helper
    func updateUI() {
        if video == nil { return }
        title = video.name!
        aboutLabel.text = video.about
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        publishedLabel.text = formatter.stringFromDate(video.date!)
        thumb.loadImageWithURL(NSURL(string: video.thumb!)!)
    }
}
