//
//  Item+CoreDataClass.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//
//

import Foundation
import CoreData

@objc(Item)
public class Item: NSManagedObject {
    func toItemType() -> FinderItem {
        fatalError()
    }
}
