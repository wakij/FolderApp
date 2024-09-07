//
//  Item+CoreDataProperties.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var isFile: Bool
    @NSManaged public var parentFolder: Folder?

}

extension Item : Identifiable {

}
