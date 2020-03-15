//
//  Entry+Convenience.swift.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import Foundation
import CoreData


enum EntryMood: String, CaseIterable {
    case sad
    case normal
    case happy
}

extension Entry{
    
    //Computed property, returns an EntryRepresentation object that is initialized from the values of the Entry.
    var entryRepresentation: EntryRepresentation? {
        
        guard let title = title, let bodyText = bodyText, let mood = mood, let timestamp = timestamp else {
            return nil
        }
        
        return EntryRepresentation(title: title, bodyText: bodyText, identifier: identifier?.uuidString , mood: mood, timestamp: timestamp)
    }
    
    //2.Convinience init from FireBase
    //This should simply pass the values from the entry representation to the convenience initializer #1 above
    //EntryRepresentation type is the struct which represent the Firebase data
    @discardableResult convenience init?( entryRepresentation: EntryRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        
        //Unwrap data to the correct format
        guard let mood = EntryMood(rawValue: entryRepresentation.mood), let identifierString =  entryRepresentation.identifier, let identifier = UUID(uuidString: identifierString) else { return nil }
        
        //Passing the data to the #1 init convinience
        self.init(title: entryRepresentation.title, bodyText: entryRepresentation.bodyText, timestamp: entryRepresentation.timestamp, identifier: identifier, mood: mood, context: context)
    }
    
    //1.Convinience init for CoreData
    @discardableResult convenience init(title: String, bodyText: String? = nil, timestamp: Date, identifier: UUID = UUID(),mood: EntryMood = .normal, context:NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context:context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.mood = mood.rawValue
        self.identifier = identifier
    }
    

    
}
