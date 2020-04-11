//
//  CallerData.swift
//  CallerData
//
//  Created by Sanjeet on 10/04/2020.
//  Copyright © 2020 Sanjeet. All rights reserved.
//

import Foundation
import CoreData

public final class CallerData {
    
    public init() {
        
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let momdName = "CallKitTutorial"
        let groupName = "group.com.ios.damsel.call"
        let fileName = "demo.sqlite"
        
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        guard let baseURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) else {
            fatalError("Error creating base URL for \(groupName)")
        }
        
        let storeUrl = baseURL.appendingPathComponent(fileName)
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        let description = NSPersistentStoreDescription()
        description.url = storeUrl
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func appGroupContainerURL() -> URL? {
        let groupName = "group.com.ios.damsel.call"
        let fileName = "demo.sqlite"
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier:groupName) else {
            return nil
        }
        
        let storagePathUrl = groupURL.appendingPathComponent(fileName)
        let storagePath = storagePathUrl.path
        if !fileManager.fileExists(atPath: storagePath) {
            do {
                try fileManager.createDirectory(atPath: storagePath,
                                                withIntermediateDirectories: false,
                                                attributes: nil)
            } catch let error {
                print("error creating filepath: \(error)")
                return nil
            }
        }
        return storagePathUrl
    }

    public var context: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }

    // MARK: - Core Data Saving support
    
    public func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func fetchRequest(blocked: Bool, includeRemoved: Bool = false, since date: Date? = nil) -> NSFetchRequest<Caller> {
        let fr: NSFetchRequest<Caller> = Caller.fetchRequest()
        var predicates = [NSPredicate]()
        
        let blockedPredicate = NSPredicate(format:"isBlocked == %@",NSNumber(value:blocked))
        predicates.append(blockedPredicate)
        
        if !includeRemoved {
            let removedPredicate = NSPredicate(format:"isRemoved == %@",NSNumber(value:false))
            predicates.append(removedPredicate)
        }
        
        if let dateFrom = date {
            let datePredicate = NSPredicate(format:"updatedDate > %@", dateFrom as NSDate)
            predicates.append(datePredicate)
        }
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        fr.predicate = predicate
        
        fr.sortDescriptors = [NSSortDescriptor(key: "number", ascending: true)]
        return fr
    }
    
}


