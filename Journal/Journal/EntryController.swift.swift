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
    
    let baseURL = URL(string: "https://jornal-2ac0f.firebaseio.com/")!
    
    func save(title: String, bodyText: String, seletedMoodIndex: Int) {
        guard !title.isEmpty else {return}
        
        let timeStamp = Date()
        
        let mood = EntryMood.allCases[seletedMoodIndex]
        
        let _ = Entry(title: title, bodyText: bodyText, timestamp: timeStamp, mood: mood)
        
        saveToPersistentStore()
    }
    
    
    
     func saveToPersistentStore() {
        do{
            try CoreDataStack.shared.mainContext.save()
        }catch{
            NSLog("Error while saving data: \(error)")
        }
    }
    
    
    
    func delete(_ task: NSManagedObject ) {
       
        CoreDataStack.shared.mainContext.delete(task)
        
        self.saveToPersistentStore()
    }
}
