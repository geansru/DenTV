//
//  Video+CoreDataProperties.swift
//  
//
//  Created by Dmitriy Roytman on 12.10.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Video {

    @NSManaged var about: String?
    @NSManaged var name: String?
    @NSManaged var thumb: String?
    @NSManaged var uid: String?
    @NSManaged var isNew: NSNumber?
    @NSManaged var isFavourite: NSNumber?
    @NSManaged var date: NSDate?
    @NSManaged var playlist: Playlist?

}
