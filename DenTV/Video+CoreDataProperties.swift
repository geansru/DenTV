//
//  Video+CoreDataProperties.swift
//  
//
//  Created by Dmitriy Roytman on 11.10.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Video {

    @NSManaged var uid: String?
    @NSManaged var name: String?
    @NSManaged var about: String?
    @NSManaged var thumb: String?
    @NSManaged var playlist: NSManagedObject?

}
