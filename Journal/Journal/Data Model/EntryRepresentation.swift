//
//  EntryRepresentation.swift
//  Journal
//
//  Created by FGT MAC on 3/15/20.
//  Copyright © 2020 FGT MAC. All rights reserved.
//

import Foundation

//Data Model for JSON coming from FireBase
// EntryRepresentation is just a version of a Entry that has the Core Data aspects of it stripped out
struct EntryRepresentation: Codable {
    var title: String
    var bodyText: String
    var identifier: String?
    var mood: String
    var timestamp: Date
}
