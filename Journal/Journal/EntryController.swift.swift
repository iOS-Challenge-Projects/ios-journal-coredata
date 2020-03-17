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
    
    
    //Initialize EntryController with fetchEntriesFromServer method
    init(){
        fetchEntriesFromServer()
    }
    
    //MARK: - FireBase
    //Firebase project URL
    let baseURL = URL(string: "https://jornal-2ac0f.firebaseio.com/")!
    
    //typealias is a way of creating a var for a existing Type
    //many times is easier to type the var/alias than the actual Type
    typealias CompletionHandler = (Error?) -> Void
    
    //Closure has an empty default value to optionaly run whatever code we want when completed
    func fetchEntriesFromServer(completion: @escaping CompletionHandler = { _ in }) {
        
        let requestURL = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            //Check if there is an error
            if let error = error {
                NSLog("Error fetching data from FB: \(error)")
                completion(error)
                return
            }
            
            //Check if data exist
            guard let data = data else {
                NSLog("No Data found in FireBase")
                completion(NSError())
                return
            }
            
            do{
                //Array of values
                let entriesRepresentation = Array(try JSONDecoder().decode([String: EntryRepresentation].self, from: data).values)
                
                self.updateEntries(with: entriesRepresentation)
                
                completion(nil)
                
            }catch{
                NSLog("Error decoding data from FB: \(error)")
            }
            
        }.resume()
    }
    
    //representation argument represents the EntryRepresentation objects that are fetched from Firebase.
    func updateEntries(with representations: [EntryRepresentation]) {
        
        //1.Fetch request from Entry
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        
        
        //Filter out the "Values" which has no identifier
        let taskID = representations.filter { $0.identifier != nil  }
        
        //Creates a new copy of "Keys" without nil identifiers for the
        let identitiesToFetch = taskID.compactMap { UUID(uuidString: $0.identifier!) }
        
        //2. Create a dictionary with the identifiers of the representations as the keys, and the values as the representations
        //zip method to combine two arrays of items together into a dictionary
        let representationByID = Dictionary(uniqueKeysWithValues: zip(identitiesToFetch, taskID))
        
        //Convert let to var
        var taskToCreate = representationByID
        
        //3. Predicate to sort
        fetchRequest.predicate = NSPredicate(format: "identifier IN %@", identitiesToFetch)
        
        do{
            //1.This will return an array of Entry objects whose identifier was in the array you passed in to the predicate
            let existingTask = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            
            //2.Iterate over the CoreData items
            for entry in existingTask{
                
                //get the specific representation using the identifier as the id
                guard let id = entry.identifier, let representation = representationByID[id] else { continue }
                
                //1.Call update method while looping to sync what match
                self.update(entry: entry, with: representation)
                
                //2.remove matching task and whats left is the new items
                taskToCreate.removeValue(forKey: id)
                
                
            }
            //3.Create new entries into CoreData of non matching itmes
            for representation in taskToCreate.values{
                Entry(entryRepresentation: representation)
            }
            //Save after loop finishes
            saveToPersistentStore()
        }catch{
            NSLog("Error fetching data: \(error)")
        }
        
        
    }
    
    //It takes in an Entry whose values should be updated, and an EntryRepresentation to take the values from
    func update(entry: Entry, with entryRepresentaiton: EntryRepresentation) {
        
        //No need to update the indetifier since it should never change
        entry.title = entryRepresentaiton.title
        entry.bodyText = entryRepresentaiton.bodyText
        entry.mood = entryRepresentaiton.mood
        entry.timestamp = entryRepresentaiton.timestamp
    }
    
    
    
    //MARK: - CoreData
    
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
