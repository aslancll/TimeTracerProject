//
//  CoreDataHandler.swift
//  Time Tracer
//
//  Created by Celal Aslan on 2018-06-15.
//  Copyright © 2018 Celal Aslan. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHandler: NSObject {
    
    /**
     Creates a singleton object to be used across the whole app easier
     
     - returns: CoreDataHandler
     */
    class var sharedInstance: CoreDataHandler {
        struct Static {
            static var instance: CoreDataHandler = CoreDataHandler()
    }
        return Static.instance
    }
    
    
    lazy var backgroundManagedObjectContext: NSManagedObjectContext = {
        let backgroundManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        let coordinator = self.persistentStoreCoordinator
        backgroundManagedObjectContext.persistentStoreCoordinator = coordinator
        return backgroundManagedObjectContext
    }()
    
    lazy var objectModel: NSManagedObjectModel = {
        let modelPath = Bundle.main.url(forResource: "Model", withExtension: "momd")
        let objectModel = NSManagedObjectModel(contentsOf: modelPath!)
        return objectModel!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.objectModel)
        
        // Get the paths to the SQLite file
        let storeURL = self.applicationDocumentsDirectory().appendingPathComponent("Model.sqlite")
        
        // Define the Core Data version migration options
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        // Attempt to load the persistent store
        var error: NSError?
        
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return persistentStoreCoordinator
    }()
    
    func applicationDocumentsDirectory() -> NSURL {
        return FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).last! as NSURL
    }
    
    func saveContext() {
        do {
            try backgroundManagedObjectContext.save()
        } catch {
            // Error occured while deleting objects
        }
    }
    
    /**
     Tells whether the passed in activity's name is already saved or not.
     
     - parameter activityName: activityName activity to be saved.
     
     - returns: BOOL boolean value determining whether the activity is already in core data or not.
     */
    func isDuplicate(activityName: String) -> Bool {
        let entityDescription = NSEntityDescription.entity(forEntityName: "Activity", in: self.backgroundManagedObjectContext)
        let request = NSFetchRequest<NSFetchRequestResult>()
        request.entity = entityDescription
        let predicate = NSPredicate(format: "name = %@", activityName)
        request.predicate = predicate
        do {
            let objects = try self.backgroundManagedObjectContext.fetch(request)
            return objects.count != 0
        } catch {
            // Error occured
            return false
        }
    }
    
    /**
     Creates a NSDateFormatter to format the dates of the Route object
     
     - returns: NSDateFormatter the dateFormatter object
     */
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        return dateFormatter
    }()
    
    /**
     Adds new activity to core data.
     
     - parameter name: name activity name to be saved.
     */
    func addNewActivityName(name: String) {
        let newActivity = NSEntityDescription.insertNewObject(forEntityName: "Activity", into: self.backgroundManagedObjectContext) as! Activity
        newActivity.name = name
        saveContext()
    }
    
    /**
     Save new log object to core data.
     
     - parameter name:      name of the activity
     - parameter startDate: when the activity started
     - parameter endDate:   when it was finished
     - parameter duration:  duration of the activity
     */
    func saveLog(name: String, duration: NSInteger) {
        let log: Logs = NSEntityDescription.insertNewObject(forEntityName: "Logs", into: self.backgroundManagedObjectContext) as! Logs
        log.name = name
        log.duration = duration as NSNumber
//        log.saveTime = dateFormatter.string(for: Calendar.current)
        saveContext()
    }
    
    /**
     Fetch core data to get all log objects.
     
     - returns: array of log objects
     */
    func allLogItems() -> [Logs]? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Logs", in: self.backgroundManagedObjectContext)
        fetchRequest.entity = entityDescription
        
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [nameDescriptor]
        
        return (fetchCoreDataWithFetchRequest(fetchRequest: fetchRequest) as! [Logs])
    }
    
    /**
     Fetch core data for activities for today
     
     - returns: array of History objects
     */
    func fetchCoreDataForTodayActivities() -> [Logs] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Logs", in: self.backgroundManagedObjectContext)
        fetchRequest.entity = entityDescription
        
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [nameDescriptor]
        
    
        let name = NSManagedObject()
        let predicate = NSPredicate(format: "(name >= %@)", name)
        fetchRequest.predicate = predicate
        
        return (fetchCoreDataWithFetchRequest(fetchRequest: fetchRequest) as! [Logs])
    }
    
    /**
     Fetch core data for all the activities
     
     - returns: array of Activity objects
     */
    func fetchCoreDataAllActivities() -> [Activity] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let entityDescription = NSEntityDescription.entity(forEntityName: "Activity", in: self.backgroundManagedObjectContext)
        fetchRequest.entity = entityDescription
        
        let nameDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [nameDescriptor]
        
        return (fetchCoreDataWithFetchRequest(fetchRequest: fetchRequest) as! [Activity])
    }
    
    /**
     Fetches Core Data with the given fetch request and returns an array with the results if it was successful.
     
     - parameter fetchRequest: request to make
     
     - returns: array of objects
     */
    func fetchCoreDataWithFetchRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [AnyObject]? {
        do {
            let fetchResults = try backgroundManagedObjectContext.fetch(fetchRequest)
            return fetchResults as [AnyObject]
        } catch {
            // error occured
        }
        
        return nil
    }
    
    /**
     Delete a single Core Data object
     
     - parameter object: object to delete
     */
    func deleteObject(object: NSManagedObject) {
        backgroundManagedObjectContext.delete(object)
        saveContext()
    }
    
    /**
     Delete multiple objects
     
     - parameter objectsToDelete: objects to delete
     */
    func deleteObjects(objectsToDelete: [NSManagedObject]) {
        for object in objectsToDelete {
            backgroundManagedObjectContext.delete(object)
        }
        saveContext()
    }
    
}
