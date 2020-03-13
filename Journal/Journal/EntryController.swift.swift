//
//  EntryController.swift.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import Foundation
import CoreData

class EntryController {
    
    
    //This will allow any changes to the persistent store become immediately visible to the user when accessing this array
    var entries: [Entry] {
        loadFromPersistentStore()
    }
    
    
    func save(title: String, bodyText: String ) {
        guard !title.isEmpty else {return}
        
        let timeStamp = Date()
        
        let _ = Entry(title: title, bodyText: bodyText, timestamp: timeStamp)
        
        saveToPersistentStore()
    }
    
    
    
     func saveToPersistentStore() {
        do{
            try CoreDataStack.shared.mainContext.save()
        }catch{
            NSLog("Error while saving data: \(error)")
        }
    }
    
    
    func loadFromPersistentStore() -> [Entry] {
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        do{
            return try CoreDataStack.shared.mainContext.fetch(fetchRequest)
        }catch{
            NSLog("Error while fetching data: \(error)")
            return []
        }
    }
    
    func delete(_ task: NSManagedObject ) {
       
        CoreDataStack.shared.mainContext.delete(task)
        
        self.saveToPersistentStore()
    }
}
