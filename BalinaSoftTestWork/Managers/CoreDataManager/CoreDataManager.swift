

import Foundation
import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
   
    
    
    public var photos : [Photo] {
        get {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
            let photos =  try! managedObjectContext.fetch(fetchRequest) as! [Photo]
            return photos.sorted(by: { (photot1, photo2) -> Bool in
                return photot1.id! < photo2.id! ? true : false
            })
        }
    }
    
    public var photoIds : [String] {
        get {
           return photos.reduce(into: [String](), { (result, photo) in
                result.append(photo.id!)
            })
        }
    }
    
    public var comments : [Comment]{
        get{
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Comment")
            let comments =  try! managedObjectContext.fetch(fetchRequest) as! [Comment]
            return comments.sorted(by: { (comment1, comment2) -> Bool in
                return comment1.id! < comment2.id! ? true : false
            })
            
        }
    }
    
    public var commentsIds : [String]{
        get{
            return comments.reduce(into: [String](), { (result, comment) in
                result.append(comment.id!)
            })
        }
    }
   
    
    //MARK: - Create fetched result controller for entity
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    func getFetchedResultController(entityName: String, sortDescriptor: String, ascending: Bool) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: sortDescriptor, ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
}


