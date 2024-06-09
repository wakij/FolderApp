//
//  FolderViewController.swift
//  FinderApp
//
//  Created by tomoshigewakita on 2024/06/09.
//

import Foundation
import UIKit

enum FinderItemType {
    case file
    case folder
}

enum FinderItem: Hashable {
    case file(FileModel)
    case folder(FolderModel)
    
    var name: String {
        switch self {
        case .file(let fileModel):
            return fileModel.text
        case .folder(let folderModel):
            return folderModel.text
        }
    }
    
    var isFile: Bool {
        switch self {
        case .file(_):
            return true
        case .folder(_):
            return false
        }
    }
    
    var id: UUID {
        switch self {
        case .file(let fileModel):
            return fileModel.id
        case .folder(let folderModel):
            return folderModel.id
        }
    }
}

enum Section: Hashable {
    case main
}

struct FileModel: Hashable {
    var id: UUID
    var text: String
}

struct FolderModel: Hashable {
    var id: UUID
    var text: String
    var itemCount: Int
}

//特定のFolderを閲覧するクラス
class FolderViewController: UIViewController {
    enum Mode {
        case edit
        case select
    }
    var finderManager: FinderManager
    var collectionView: FolderCollectionVidw!
    var fileReg: UICollectionView.CellRegistration<FinderCellView, FileModel>!
    var folderReg: UICollectionView.CellRegistration<FinderCellView, FolderModel>!
    var dataSource: UICollectionViewDiffableDataSource<Section,
    FinderItem>!
    
    var folder: Folder
    var mode: Mode = .edit {
        didSet {
            switch mode {
            case .edit:
                self.collectionView.isEditing = false
                self.collectionView.allowsMultipleSelectionDuringEditing = false
            case .select:
                self.collectionView.isEditing = true
                self.collectionView.allowsMultipleSelectionDuringEditing = true
            }
        }
    }
    
    init(folder: Folder ,finderManager: FinderManager) {
        self.finderManager = finderManager
        self.folder = folder
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setUpNavigationBar()
        self.setUpCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
        collectionView.reloadData()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 200, height: 200)
        layout.sectionInset = .init(top: 50, left: 50, bottom: 50, right: 50)
        layout.minimumLineSpacing = 50
        self.collectionView = FolderCollectionVidw(frame: .zero, collectionViewLayout: layout)
        self.collectionView.delegate = self
        self.fileReg = UICollectionView.CellRegistration<FinderCellView, FileModel> { [weak self](cell,indexPath,itemIdentifier) in
            guard let self else { return }
//            以前の状態を引き継ぐ必要がある
            cell.contentConfiguration = FileContentView.FileConfiguration(nameText: itemIdentifier.text, isMultiSelected: false)
            cell.isMultipleTouchMode = self.mode == .select
            cell.renameDelegate = self
        }
        
        self.folderReg = UICollectionView.CellRegistration<FinderCellView, FolderModel> { [weak self](cell,indexPath,itemIdentifier) in
            guard let self else { return }
            cell.contentConfiguration = FolderContentView.FolderConfiguration(nameText: itemIdentifier.text, itemNum: itemIdentifier.itemCount, isMultiSelected: false)
            cell.backgroundConfiguration = cell.defaultBackgroundConfiguration()
            cell.isMultipleTouchMode = self.mode == .select
            cell.renameDelegate = self
        }
        
        self.dataSource = UICollectionViewDiffableDataSource<Section, FinderItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemIdentifier: FinderItem) -> FinderCellView? in
            
            
            switch itemIdentifier {
            case .file(let fileModel):
                return collectionView.dequeueConfiguredReusableCell(using: self.fileReg, for: indexPath, item: fileModel)
            case .folder(let folderModel):
                return collectionView.dequeueConfiguredReusableCell(using: self.folderReg, for: indexPath, item: folderModel)
            }
        }
        
        self.collectionView.dataSource = dataSource
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        
//        drag and drop
        self.collectionView.dragInteractionEnabled = true
        self.collectionView.dragDelegate = self
        self.collectionView.dropDelegate = self
        
//        drag中にfolderにアイテムを持っていくとそのフォルダに入ることができるようになる
        self.collectionView.isSpringLoaded = true
        
        self.view.addSubview(self.collectionView)
        
        NSLayoutConstraint.activate([
            self.collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
        ])
    }
    
    
    func update() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, FinderItem>()
        snapshot.appendSections([.main])
        

        guard let items = folder.items?.compactMap({ $0 as? Item }).map({
            $0.toItemType()
        }).sorted(by: { $0.name < $1.name }) else { return }
//
        snapshot.appendItems(items, toSection: .main)
        self.dataSource.apply(snapshot)
    }
    
    
    func setUpNavigationBar() {
        self.navigationItem.style = .editor
        switch mode {
        case .edit:
            self.navigationItem.hidesBackButton = false
            self.navigationItem.renameDelegate = self
            self.title = self.folder.name
            let addFile = UIAction(title: "ファイルを追加", handler: { [weak self] _ in
                guard let self else { return }
                showAlert(type: .file)
            })
            
            let addFolder = UIAction(title: "フォルダを追加", handler: {
                [weak self] _ in
                guard let self else { return }
                showAlert(type: .folder)
            })
            
            let addButton = UIBarButtonItem(systemItem: .add, menu: UIMenu(children: [addFile, addFolder]))
            
    //        選択ボタン
            let selectModeButton = UIBarButtonItem(title: "選択", image: nil, target: self, action: #selector(setSelectOn))
            self.navigationItem.rightBarButtonItems = [addButton, selectModeButton]
        case .select:
            self.navigationItem.hidesBackButton = true
            self.navigationItem.renameDelegate = nil
            self.title = "アイテムを選択"
            let selectModeButton = UIBarButtonItem(title: "完了", image: nil, target: self, action: #selector(setSelectOff))
            self.navigationItem.rightBarButtonItems = [ selectModeButton]
        }
    }
    
    func updateNaviBar() {
        if let selectedIndexPaths = self.collectionView.indexPathsForSelectedItems {
            if selectedIndexPaths.count > 0 {
                self.title = String(selectedIndexPaths.count) + "項目を選択中"
                return
            }
        }
        self.title = "アイテムを選択"
    }
    
//    var isEditing -> なぞって何かが可能かどうか
    @objc func setSelectOn() {
        mode = .select
        collectionView.reloadData()
        setUpNavigationBar()
    }
    
    @objc func setSelectOff() {
        mode = .edit
        collectionView.reloadData()
        setUpNavigationBar()
    }
    
    func showAlert(type: FinderItemType) {
        var textFieldOnAlert = UITextField()
        let alert = UIAlertController(title: "名前を入力",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textFieldOnAlert = textField
            textFieldOnAlert.returnKeyType = .done
        }

        let doneAction = UIAlertAction(title: "決定", style: .default) { [weak self](_) in
            guard let self else { return }
            switch type {
            case .file:
                let newFile: File = self.finderManager.new()
                newFile.name = textFieldOnAlert.text
                newFile.parentFolder = folder
            case .folder:
                let newFolder: Folder = self.finderManager.new()
                newFolder.name = textFieldOnAlert.text
                newFolder.parentFolder = folder
            }
            finderManager.save()
            self.update()
            dismiss(animated: true)
        }

        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { [weak self](_) in
            guard let self else { return }
            dismiss(animated: true)
        }

        alert.addAction(doneAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension FolderViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
//        contextMenuは同時に出すことができない仕様にしている
        guard let indexPath = indexPaths.first else { return nil }
        guard let itemModel = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        return UIContextMenuConfiguration(actionProvider:  { suggestedActions in
            let deleteAction = UIAction(title: "削除", handler: { [weak self](_) in
                self?.finderManager.delete(id: itemModel.id)
                self?.update()
            })
            return UIMenu(children: [deleteAction])
        })
    }
    
//    これでfalseを返すとそもそもspring loadedの対象にならないっぽい
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return false }
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return false }
        
        if collectionView.hasActiveDrag {
            if item.isFile || cell.configurationState.cellDragState == .dragging {
                return false
            }
        }
        
        return true
    }
    
//    複数選択時
//    selected状態のセルをもう一度tapすると呼ばれる
//    通常時
//    あるセルがselectedで他のセルをtapすると呼ばれる
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath), let finderCell = cell as? FinderCellView else { return }
        
        if mode == .select {
            updateNaviBar()
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let cell = collectionView.cellForItem(at: indexPath), let finderCell = cell as? FinderCellView else { return }
                
        if mode == .select {
            updateNaviBar()
            return
        }
        
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        
//        対応するcoredataModelを取得
        if item.isFile {
//            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
//                let pickerView = UIImagePickerController()
//                pickerView.sourceType = .photoLibrary
//                pickerView.delegate = self
//                self.present(pickerView, animated: true)
//            }
        } else {
            guard let folder: Folder = self.finderManager.fetch(id: item.id) else {
                return
            }
            let folderViewController = FolderViewController(folder: folder, finderManager: finderManager)
            navigationController?.pushViewController(folderViewController, animated: true)
        }
//
    }
}

extension FolderViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return [] }
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: any UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return [] }
        let draggingItems = session.items.map({ $0.localObject as? FinderItem })
        if draggingItems.contains(where: { $0 == item }) {
            return []
        }
        if !item.isFile { return [] }
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension FolderViewController: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: any UICollectionViewDropCoordinator) {
        
        let dragItems = coordinator.items.compactMap({ $0.dragItem.localObject as? FinderItem })
        let dragFileItems = dragItems.compactMap({ self.finderManager.fetch(id: $0.id) })
        if dragItems.count != dragFileItems.count { return }
        
        guard let rootDragFileItem = dragFileItems.first else { return }
        

        if rootDragFileItem.parentFolder == self.folder {
    //        同じcollectionViewの時
            if let destinationIndexPath = coordinator.destinationIndexPath, let item = self.dataSource.itemIdentifier(for: destinationIndexPath) {
                if !item.isFile {
                    guard let folder: Folder = self.finderManager.fetch(id: item.id) else { return }
                    dragFileItems.forEach({ $0.parentFolder = folder })
                }
            }
        } else {
//        階層が違うcollectionViewの時
            if let destinationIndexPath = coordinator.destinationIndexPath, let item = self.dataSource.itemIdentifier(for: destinationIndexPath) {
                if !item.isFile {
                    guard let folder: Folder = self.finderManager.fetch(id: item.id) else { return }
                    dragFileItems.forEach({ $0.parentFolder = folder })
                } else {
                    dragFileItems.forEach({ $0.parentFolder = self.folder })
                }
            } else {
                dragFileItems.forEach({ $0.parentFolder = self.folder })
            }
        }
        
        update()
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: any UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
//        始点と目的地が同じならcancel
//        フォルダAがフォルダAにはいるのを防ぐ
        if let dragItem = session.items.first?.localObject as? FinderItem, let destinationIndexPath, let destinationItem = self.dataSource.itemIdentifier(for: destinationIndexPath) {
            if dragItem.id == destinationItem.id {
                return .init(operation: .cancel, intent: .unspecified)
            }
        }
        
//        目的地がfolderなら移動させる
        if let destinationIndexPath, let item = self.dataSource.itemIdentifier(for: destinationIndexPath) {
            if !item.isFile {
                return .init(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
        }
        
//        目的地がファイルまたはセルが存在しない場所の場合
//  dragしているアイテムの先頭要素が現在のフォルダから移動しないのであればキャンセルする(標準のfinderと同じ仕様)
        if let item = session.items.first?.localObject as? FinderItem, let folder = finderManager.fetch(id: item.id), let parentFolder = folder.parentFolder {
            if parentFolder.id == self.folder.id {
                return .init(operation: .cancel, intent: .unspecified)
            }
        }
        
        return .init(operation: .move, intent: .unspecified)
    }
}

extension FolderViewController: UINavigationItemRenameDelegate {
    func navigationItem(_: UINavigationItem, didEndRenamingWith title: String) {
        self.folder.name = title
        self.finderManager.save()
    }
}

extension FolderViewController: FinderItemNameFiledDelegate {
    func shouldBeginTextFiled(cell: FinderCellView, textFiled: UITextField) -> Bool {
        if collectionView.hasActiveDrag {
            return false
        }
        return true
    }
    
    func didEndEditTextFiled(cell: FinderCellView, textFiled: UITextField) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard let itemWrapper = self.dataSource.itemIdentifier(for: indexPath) else { return }
        guard let item = self.finderManager.fetch(id: itemWrapper.id) else { return }
        item.name = textFiled.text
        self.finderManager.save()
    }
}


final class FolderCollectionVidw: UICollectionView {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.next?.touchesBegan(touches, with: event)
        super.touchesBegan(touches, with: event)
    }
}

extension FolderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.originalImage] as! UIImage
        self.dismiss(animated: true) // 選択画面を閉じる
        
        guard let selectedIndex = collectionView.indexPathsForSelectedItems?.first else { return }
        guard let file = self.dataSource.itemIdentifier(for: selectedIndex) else { return }
        
        let canvasViewController = CanvasViewController(image: image)
        canvasViewController.modalPresentationStyle = .fullScreen
        self.present(canvasViewController, animated: true)
    }
}
