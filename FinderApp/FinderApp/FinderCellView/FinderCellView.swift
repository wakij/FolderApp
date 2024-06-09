//
//  FinderCellView.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import UIKit

class FinderCellView: UICollectionViewCell {
    weak var renameDelegate: FinderItemNameFiledDelegate? {
        didSet {
            guard let finderItem = contentView as? FinderContentView else { return }
            finderItem.delegate = self
        }
    }
    var isMultiSelected: Bool = false {
        didSet {
            if oldValue != isMultiSelected {
                setNeedsUpdateConfiguration()
            }
        }
    }
    
    override var configurationState: UICellConfigurationState {
        // Get the structure from UIKit with the system properties set by calling super.
        var state = super.configurationState

        // Set the custom property on the state.
        state.isMultiSelected = isMultiSelected
        return state
    }
    
//  再生成するときに以前の状態を引き継がないようにする
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isMultiSelected = false
    }
    
    override func updateConfiguration(using state: UICellConfigurationState) {
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        if state.isSelected {
            backgroundConfiguration.backgroundColor = .clear
        }
        if state.isHighlighted {
            backgroundConfiguration.backgroundColor = .clear
        }
        self.backgroundConfiguration = backgroundConfiguration
    }
}

extension FinderCellView: FinderContetnViewDelegate {
    func shouldBeginTextFiled(textFiled: UITextField) -> Bool {
        return renameDelegate?.shouldBeginTextFiled(cell: self, textFiled: textFiled) ?? false
    }
    
    func didEndEditTextFiled(textFiled: UITextField) {
        renameDelegate?.didEndEditTextFiled(cell: self, textFiled: textFiled)
    }
}
