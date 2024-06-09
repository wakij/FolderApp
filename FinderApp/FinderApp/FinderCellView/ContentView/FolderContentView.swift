//
//  FolderContentView.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import UIKit


final class FolderContentView: UIView, UIContentView, FinderContentView {
    weak var delegate: (any FinderContetnViewDelegate)?
    
    struct FolderConfiguration: UIContentConfiguration, Hashable {
        var nameText: String
        var itemNum: Int
        var isMultiSelected: Bool = false
        
        func makeContentView() -> any UIView & UIContentView {
            return FolderContentView(configuration: self)
        }
        
        func updated(for state: any UIConfigurationState) -> FolderContentView.FolderConfiguration {
            var conf = self
            if let state = state as? UICellConfigurationState {
                conf.isMultiSelected = state.isMultiSelected
            }
            return conf
        }
    }
    
    var imageView: UIImageView!
    var nameLable: UITextField!
    private var itemCountLabel: UILabel!
    private var checkMark: UIImageView!
    
    private var appliedConfiguration: FolderConfiguration!
    
    var configuration: any UIContentConfiguration {
        get {
            return appliedConfiguration
        } set {
            self.apply(configuration: newValue as! FolderConfiguration)
        }
    }
    
    init(configuration: FolderConfiguration) {
        super.init(frame: .zero)
        setUpInternalView()
        apply(configuration: configuration)
    }
    
    func apply(configuration: FolderConfiguration) {
//        変更がない場合は更新しないため
        guard appliedConfiguration != configuration else { return }
        appliedConfiguration = configuration
        
        nameLable.text = configuration.nameText
        itemCountLabel.text = configuration.itemNum.formatted() + "項目"
        checkMark.isHidden = !appliedConfiguration.isMultiSelected
    }
    
    private func setUpInternalView() {
        imageView = UIImageView(image: UIImage(named: "folder"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        nameLable = UITextField()
        nameLable.delegate = self
        nameLable.textAlignment = .center
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        
        itemCountLabel = UILabel()
        itemCountLabel.textAlignment = .center
        itemCountLabel.numberOfLines = 1
        itemCountLabel.translatesAutoresizingMaskIntoConstraints  = false
        itemCountLabel.textColor = .lightGray
        itemCountLabel.adjustsFontSizeToFitWidth = true
        
        checkMark = UIImageView(image: UIImage(systemName: "checkmark.circle"))
        checkMark.contentMode = .scaleAspectFit
        checkMark.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(imageView)
        self.addSubview(nameLable)
        self.addSubview(itemCountLabel)
        self.addSubview(checkMark)
        
//        領域を上80%と20%にわける
//        80%のうち90%をimageViewに割り当てる
//        もとの20%をnameLabelに割り当てる
        
        let imageViewbox = UILayoutGuide()
        self.addLayoutGuide(imageViewbox)
        
        NSLayoutConstraint.activate([
            imageViewbox.topAnchor.constraint(equalTo: self.topAnchor),
            imageViewbox.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.75),
            imageViewbox.widthAnchor.constraint(equalTo: self.widthAnchor),
            imageViewbox.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerXAnchor.constraint(equalTo: imageViewbox.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: imageViewbox.centerYAnchor),
            imageView.heightAnchor.constraint(equalTo: imageViewbox.heightAnchor, multiplier: 0.95),
            imageView.widthAnchor.constraint(equalTo: imageViewbox.widthAnchor),
            nameLable.topAnchor.constraint(equalTo: imageViewbox.bottomAnchor),
            nameLable.widthAnchor.constraint(equalTo: self.widthAnchor),
            nameLable.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            nameLable.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.15),
            itemCountLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            itemCountLabel.topAnchor.constraint(equalTo: nameLable.bottomAnchor),
            itemCountLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            itemCountLabel.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1),
            checkMark.centerXAnchor.constraint(equalTo: imageViewbox.centerXAnchor),
            checkMark.centerYAnchor.constraint(equalTo: imageViewbox.centerYAnchor),
            checkMark.widthAnchor.constraint(equalToConstant: 50),
            checkMark.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FolderContentView: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if self.delegate?.shouldBeginTextFiled(textFiled: textField) ?? false {
            textField.backgroundColor = .secondarySystemFill
            textField.layer.cornerRadius = 10
            self.itemCountLabel.isHidden = true
            return true
        }
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .clear
        textField.layer.cornerRadius = 0.0
        self.itemCountLabel.isHidden = false
        self.delegate?.didEndEditTextFiled(textFiled: textField)
    }
}
