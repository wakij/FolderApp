//
//  FinderItemNameFiledDelegate.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import UIKit

protocol FinderContentView: AnyObject {
    var delegate: FinderContetnViewDelegate? { get set }
}

protocol FinderContetnViewDelegate: AnyObject {
    func shouldBeginTextFiled(textFiled: UITextField) -> Bool
    func didEndEditTextFiled(textFiled: UITextField)
}

protocol FinderItemNameFiledDelegate: AnyObject {
    func shouldBeginTextFiled(cell: FinderCellView,  textFiled: UITextField) -> Bool
    func didEndEditTextFiled(cell: FinderCellView, textFiled: UITextField)
}
