//
//  CoreDataStack.swift
//  DenTV
//
//  Created by Dmitriy Roytman on 11.10.15.
//  Copyright © 2015 Dmitriy Roytman. All rights reserved.
//

import CoreData

let dataStorageName = "DenTV"
let RESOURCE_NAME = "DenTV"
class CoreDataStack {
    let context: NSManagedObjectContext
    let psc: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let store: NSPersistentStore?
    
    class func applicationDocumentsDirectory() -> NSURL {
        let fileManager = NSFileManager.defaultManager()
        
        let urls = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask) 
        return urls[0]
    }
    
    init() {
        let bundle = NSBundle.mainBundle()
        let modelURL = bundle.URLForResource(RESOURCE_NAME, withExtension: "momd")
        
        model = NSManagedObjectModel(contentsOfURL: modelURL!)!
        psc = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        context = NSManagedObjectContext()
        
        context.persistentStoreCoordinator = psc
        
        let documentURL = CoreDataStack.applicationDocumentsDirectory()
        let storeURL = documentURL.URLByAppendingPathComponent(RESOURCE_NAME)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true]
        
        do {
        store = try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options)
        } catch let error as NSError {
            print(error.localizedDescription); abort()
        }
    }
    
    func save() {
        if context.hasChanges {
            do {
                try context.save()
            } catch let error as NSError {
                print(__FUNCTION__)
                print(error.localizedDescription)
            }
        }
    }
    
}