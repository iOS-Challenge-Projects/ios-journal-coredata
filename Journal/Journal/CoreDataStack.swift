//
//  CoreDataStack.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import Foundation
import CoreData


class CoreDataStack {
    
    //This is a singleton which is a shared single session/instance of the class CoreDataStack
    static let shared = CoreDataStack()
    
    //Lazy means that the code will not run unlesss we need it or invoke it
    lazy var container: NSPersistentContainer = {
        
        //The name must match the data model name
        let container = NSPersistentContainer(name: "Journal")
        
        container.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistant stores: \(error)")
            }
        }
        
        //1.Merge changes from both context
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    var mainContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    //Takes in a secondary background context but if nothing is
    //pass in the argument it defaults to main context
    func save(context: NSManagedObjectContext = CoreDataStack.shared.mainContext) throws {
        
        var error: Error?

        context.performAndWait {
            do {
                try context.save()
            } catch let saveError {
                error = saveError
            }
        }
        
        if let error = error { throw error }
        
    }
}

