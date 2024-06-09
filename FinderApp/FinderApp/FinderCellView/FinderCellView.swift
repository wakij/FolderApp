//
//  FinderCellView.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import UIKit

//UICollectionViewListCellは選択状態だとデフォで背景が灰色になる
class FinderCellView: UICollectionViewCell {
    weak var renameDelegate: FinderItemNameFiledDelegate? {
        didSet {
            guard let finderItem = contentView as? FinderContentView else { return }
            finderItem.delegate = self
        }
    }
    
    var isMultipleTouchMode: Bool = false
    
    override var configurationState: UICellConfigurationState {
        // Get the structure from UIKit with the system properties set by calling super.
        var state = super.configurationState

        // Set the custom property on the state.
        if isMultipleTouchMode {
            state.isMultiSelected = isSelected
        }
        
        return state
    }
    
//    collectionView?.reloadData() or reuseの時
//  再生成するときに以前の状態を引き継がないようにする
    override func prepareForReuse() {
        super.prepareForReuse()
        self.isMultipleTouchMode = false
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
