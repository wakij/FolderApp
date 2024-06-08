//
//  File+CoreDataProperties.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//
//

import Foundation
import CoreData


extension File {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<File> {
        return NSFetchRequest<File>(entityName: "File")
    }
    
    override public func awakeFromInsert() {
        self.isFile = true
    }


}
