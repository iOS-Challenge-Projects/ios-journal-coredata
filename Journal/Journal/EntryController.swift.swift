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
    
    //Create new entries and update current ones to Firebase
    func put(entry: Entry, completion: @escaping CompletionHandler = { _ in }) {
        
        let uuid = entry.identifier ?? UUID()
        
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathComponent(".json")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "PUT"
        
        
        do {
            guard var representation = entry.entryRepresentation else {
                completion(NSError())
                return
            }
            
            //Ensure both CD and FB has the same UUID
            representation.identifier = uuid.uuidString
            entry.identifier = uuid
            
            
            //cunstructing the body of the request
            request.httpBody =  try JSONEncoder().encode(representation)
            
        } catch {
            NSLog("Error encoding data: \(error)")
        }
        
        //Perform http request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error{
                
                completion(error)
            }
            //print("Firebase response: \(response!)")
            //if there is no error pass nil to signal no issues
            completion(nil)
            
        }.resume()
        
    }
    
    //Delete FireBase
    func deleteEntryFromServer(entry: Entry, completion: @escaping CompletionHandler = {_ in }) {
        
        guard let uuid = entry.identifier else {
            return
        }
        
        //Constructing URL
        let requestURL = baseURL.appendingPathComponent(uuid.uuidString).appendingPathComponent(".json")
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(error)
                return
            }
            //print(response!)
            completion(nil)
            
        }.resume()
    }
    
    //Sync CD with FB / Fetch data from FB
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
        
        //Creating new BG context
        let newBGContext = CoreDataStack.shared.container.newBackgroundContext()
        
        //Wrap do block
        newBGContext.performAndWait {
            
            do{
                //1.This will return an array of Entry objects whose identifier was in the array you passed in to the predicate
                let existingTask = try newBGContext.fetch(fetchRequest)
                
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
                    Entry(entryRepresentation: representation,context: newBGContext)
                }
                
                try CoreDataStack.shared.save(context: newBGContext)
                
            }catch{
                NSLog("Error fetching data: \(error)")
            }
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
        
        //create instance and when calling saveToPersistentStore save it to CD
        let entry = Entry(title: title, bodyText: bodyText, timestamp: timeStamp, mood: mood)
        
        //Save it in FireBase
        put(entry: entry)
        
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        do{
            try CoreDataStack.shared.save()
        }catch{
            NSLog("Error while saving data: \(error)")
        }
    }
    
    func delete(_ task: NSManagedObject ) {
        
        //This will affect UI so mut be in main queu
        DispatchQueue.main.async {
            
            CoreDataStack.shared.mainContext.delete(task)
            do{
                try CoreDataStack.shared.save()
            }catch{
                CoreDataStack.shared.mainContext.reset()
                NSLog("Error while saving data: \(error)")
            }
        }
        
    }
}
