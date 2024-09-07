//
//  Ex+CellState.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import UIKit

extension UIConfigurationStateCustomKey {
    static let isMultiSelected = UIConfigurationStateCustomKey("com.FinderApp.Cell.isMultiSelected")
}

extension UICellConfigurationState {
    var isMultiSelected: Bool {
        get {
            return self[.isMultiSelected] as? Bool ?? false
        }
        set {
            self[.isMultiSelected] = newValue
        }
    }
}
