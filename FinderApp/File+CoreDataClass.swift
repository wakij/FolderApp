//
//  File+CoreDataClass.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//
//

import Foundation
import CoreData

@objc(File)
public class File: Item {
    override func toItemType() -> FinderItem {
        return .file(FileModel(id: self.id!, text: self.name!))
    }
}
