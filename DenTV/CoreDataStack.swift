//
//  CoreDataStack.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import CoreData

let dataStorageName = "DenTV"
class CoreDataStack {
    let context:NSManagedObjectContext
    let psc:NSPersistentStoreCoordinator
    let model:NSManagedObjectModel
    let store:NSPersistentStore?
    
    init() {
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource(dataStorageName, withExtension: "momd")!
        model = NSManagedObjectModel(contentsOfURL: modelURL)! //1
        psc = NSPersistentStoreCoordinator(managedObjectModel: model) //2
        context = NSManagedObjectContext() //3
        context.persistentStoreCoordinator = psc
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        var applicationDocumentDirectory: NSURL {
            let directory: NSSearchPathDirectory = NSSearchPathDirectory.DocumentDirectory
            let domainMask = NSSearchPathDomainMask.UserDomainMask
            let paths = NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
            let path = paths[0]
            return NSURL(string: path)!
        }
        let url = applicationDocumentDirectory.URLByAppendingPathComponent(dataStorageName)
        let storeType = NSSQLiteStoreType
        store = try! psc.addPersistentStoreWithType(storeType,
            configuration: nil,
            URL: url,
            options: options
        )
    }
    
}