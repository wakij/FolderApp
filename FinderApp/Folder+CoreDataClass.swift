//
//  Folder+CoreDataClass.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//
//

import Foundation
import CoreData

@objc(Folder)
public class Folder: Item {
    override func toItemType() -> FinderItem {
        return .folder(FolderModel(id: self.id!, text: self.name!, itemCount: self.items?.count ?? 0))
    }
}
