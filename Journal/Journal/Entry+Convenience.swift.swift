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
    
    convenience init(title: String, bodyText: String? = nil, timestamp: Date, identifier: String = UUID().uuidString,mood: EntryMood = .normal, context:NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context:context)
        self.title = title
        self.bodyText = bodyText
        self.timestamp = timestamp
        self.mood = mood.rawValue

    }
}
