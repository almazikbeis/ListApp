//
//  func.swift
//  ListApp
//
//  Created by Almaz Beisenov on 09.12.2024.
//


import Foundation
import CoreData

extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var title: String?
    @NSManaged public var content: String?
    @NSManaged public var date: Date?
}
