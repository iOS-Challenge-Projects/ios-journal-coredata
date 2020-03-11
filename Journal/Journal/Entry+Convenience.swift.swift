//
//  Entry+Convenience.swift.swift
//  Journal
//
//  Created by FGT MAC on 3/10/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import Foundation
import CoreData

extension Entry{
    
    convenience init(title: String, bodyText: String? = nil, timestamp: Date =  Date(), identifier: String = UUID().uuidString, context:NSManagedObjectContext = CoreDataStack.shared.mainContext){
        
        self.init(context:context)
        self.title = title
        self.bodyText = bodyText

    }
}