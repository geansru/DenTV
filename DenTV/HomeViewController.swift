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
    var managedContext: NSManagedObjectContext!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension HomeViewController: ContentDelegate {
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
        Log.m(status.entityValue)
    }
}