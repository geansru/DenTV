//
//  VideoDetailsViewController.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 12.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import UIKit
import CoreData
import youtube_ios_player_helper

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
    
//    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var player: YTPlayerView!
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
        case (0, 0):
            player.playVideo()
        default: break
        }
    }
    
}


extension VideoDetailsViewController {
    // MARK: Helper
    func updateUI() {
        if video == nil { return }
        let url = NSURL(string: video.uid!)!
        title = video.name!
        aboutLabel.text = video.about
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.MediumStyle
        publishedLabel.text = formatter.stringFromDate(video.date!)
        player.loadWithVideoId(video.uid!)
    }
}
