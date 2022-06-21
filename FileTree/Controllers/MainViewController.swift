//
//  ViewController.swift
//  FileTree
//
//  Created by Tetiana Sierikova on 12.06.2022.
//
//
import UIKit
import GoogleSignIn
import GoogleAPIClientForREST
import MobileCoreServices
import UniformTypeIdentifiers
import Security

class MainViewController: UIViewController {
    
    private enum NavBarButtons: String, CaseIterable {
        case account
        case addFile
        case addFolder
        var buttonImage: UIImage {
            switch self {
            case .account: return  UIImage(systemName: "person") ?? UIImage()
            case .addFile: return  UIImage(systemName: "doc.badge.plus") ?? UIImage()
            case .addFolder: return  UIImage(systemName: "folder.badge.plus") ?? UIImage()
            }
        }
        
        enum ButtonListGridImage: String, CaseIterable {
            case table
            case grid
            var buttonImage: UIImage {
                switch self {
                case .table: return UIImage(systemName: "rectangle.grid.1x2") ?? UIImage()
                case .grid: return  UIImage(systemName: "square.grid.2x2") ?? UIImage()
                }
            }
        }
    }
    
    private enum FileDirectory: String, CaseIterable {
        case file
        case directory
        var image: UIImage {
            switch self {
            case .file: return UIImage(systemName: "doc.text") ?? UIImage()
            case .directory: return UIImage(systemName: "folder") ?? UIImage()
            }
        }
    }
    
    private enum ItemType: String {
        case directory = "d"
        case file = "f"
    }
    
    private let backBarButtonItem: UIBarButtonItem = {
        let backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        backBarButtonItem.tintColor = .black
        return backBarButtonItem
    }()
    
    private lazy var isEmptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Directory is Empty"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 25, weight: .heavy)
        label.textColor = .black
        label.backgroundColor = .white
        label.isHidden = true
        return label
    }()
    
    private lazy var listCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: 50)
        collectionFlowLayout.minimumInteritemSpacing = 5
        collectionFlowLayout.minimumLineSpacing = 5
        collectionFlowLayout.scrollDirection = .vertical
        return collectionFlowLayout
    }()
    
    private lazy var gridCVLayout: UICollectionViewFlowLayout = {
        let collectionFlowLayout = UICollectionViewFlowLayout()
        let itemPerLine = 3.0
        let spacing = 5.0
        let width = UIScreen.main.bounds.size.width - spacing * CGFloat(itemPerLine - 1)
        collectionFlowLayout.scrollDirection = .vertical
        collectionFlowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionFlowLayout.itemSize = CGSize(width: width/itemPerLine, height: width / itemPerLine * 1.5)
        collectionFlowLayout.minimumInteritemSpacing = spacing
        collectionFlowLayout.minimumLineSpacing = spacing
        return collectionFlowLayout
    }()
    
    private var collectView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout.init())
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    private let spreadsheetIdDefault = "1vwFQ6PxiCOiXf41QLRrzy6yNI5M9Fg63XT_4X7_uVKs"
//        private let spreadsheetIdDefault = "1oL1cByCpMXJMz6ifaKDiK6bZC2xE2HkRA4jwHRtRuj8"
    var isRedifineSheet: Bool = false
    var user: GIDGoogleUser? = nil
    lazy var spreadsheetId = spreadsheetIdDefault
    private var userDataManager = UserDataManager()
    private var isListView: Bool = true
    private var userNode = [Node]()
    private var dataToPresent = [Node]()
    private var userTap: Int = 0
    private var totalCountNodes: Int = 0
    private var iterateCounter: Int = 0
    private var tempCounter = [String]()
    private var isRoot: Bool = true
    private var isUpdated: Bool = false
    private var parentItemIfDirectIsEmpty: String = ""
    private var titleOfScreen = "File Tree"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleOfScreen
        view.backgroundColor = .white
        view.addSubview(collectView)
        view.addSubview(isEmptyLabel)
        userDataManager.delegate = self
        collectView.dataSource = self
        collectView.delegate = self
        collectView.register(Cell.self, forCellWithReuseIdentifier: Cell.identifier)
        collectView.collectionViewLayout = listCVLayout
        navigationItem.backBarButtonItem = backBarButtonItem
        addLongTap()
        restoreSignIn()
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: NavBarButtons.ButtonListGridImage.table.buttonImage, style:.plain, target: self, action: #selector(tapChangeGridList)), UIBarButtonItem(image: NavBarButtons.addFolder.buttonImage, style:.plain, target: self, action: #selector(tapAddFolder)), UIBarButtonItem(image: NavBarButtons.addFile.buttonImage, style:.plain, target: self, action: #selector(tapAddFile))]
        if dataToPresent.isEmpty && isRoot && !isRedifineSheet {
            self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: NavBarButtons.account.buttonImage, style:.plain, target: self, action: #selector(tapAccount))]
            userDataManager.getPublicDataRequest(sheetID: spreadsheetId)
        } else {
            self.title = titleOfScreen
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if spreadsheetId == "" {
            spreadsheetId = spreadsheetIdDefault
        }
        if isRedifineSheet {
            userDataManager.getPublicDataRequest(sheetID: spreadsheetId)
            isRedifineSheet = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let navC = navigationController else { return }
        if navC.viewControllers.firstIndex(of: self) != nil { return }
        guard let destVC = navC.viewControllers.last as? MainViewController else { return }
        destVC.totalCountNodes = totalCountNodes
        destVC.userNode = userNode
        destVC.userTap = userTap
    }
    
    override func viewWillLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.activate([
            collectView.topAnchor.constraint(equalTo: view.topAnchor),
            collectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        listCVLayout.itemSize = CGSize(width: view.frame.width, height: 50)
        listCVLayout.invalidateLayout()
        isEmptyLabel.frame = CGRect(x: view.frame.midX, y: view.frame.midY, width: view.frame.size.width, height: view.frame.height)
        isEmptyLabel.center = view.center
    }
    
    @objc func tapAccount() {
        self.navigationController?.pushViewController(AccountViewController(), animated: true)
    }
    
    @objc func tapAddFolder() {
        if user?.authentication != nil {
            presentAlert(title: "Create new empty folder", alertMessage: "", withTextField: true)
        } else {
            presentAlert(title: "Error", alertMessage: "Please, sign-in Google account for add new files.", withTextField: false)
        }
    }
    
    @objc func tapAddFile() {
        if user?.authentication != nil {
            presentFilePicker()
        } else {
            presentAlert(title: "Error", alertMessage: "Please, sign-in Google account for add new files.", withTextField: false)
        }
    }
    
    @objc func tapChangeGridList() {
        isListView = !isListView
        collectView.setCollectionViewLayout(isListView ? listCVLayout : gridCVLayout, animated: true)
        navigationItem.rightBarButtonItems?[0].image = isListView ? NavBarButtons.ButtonListGridImage.table.buttonImage : NavBarButtons.ButtonListGridImage.grid.buttonImage
    }
    
    // MARK: - Handle restore sign-in Google account
    
    private func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn {user, error in
            if error == nil || user != nil {
                self.user = user
            }
        }
    }
}

// MARK: - CollectionView delegate and dataSource

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataToPresent.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.identifier, for: indexPath) as? Cell else { return UICollectionViewCell() }
        cell.title.text = dataToPresent[indexPath.row].itemName
        if dataToPresent[indexPath.row].itemType == ItemType.file.rawValue {
            cell.image.image = FileDirectory.file.image
        } else {
            cell.image.image = FileDirectory.directory.image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        userTap = indexPath.row
        if dataToPresent[userTap].itemType == ItemType.directory.rawValue {
            let viewController = MainViewController()
            if dataToPresent[userTap].children.count == 0 {
                viewController.isEmptyLabel.isHidden = false
            } else {
                isEmptyLabel.isHidden = true
            }
            viewController.parentItemIfDirectIsEmpty = dataToPresent[userTap].itemUUID
            viewController.dataToPresent = dataToPresent[userTap].children
            viewController.userNode = userNode
            viewController.titleOfScreen = dataToPresent[userTap].itemName
            viewController.userTap = userTap
            viewController.totalCountNodes = totalCountNodes
            viewController.isRoot = false
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - Long Tap to delete item

extension MainViewController {
    
    private func addLongTap() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.view.addGestureRecognizer(longPressRecognizer)
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        if user?.authentication != nil {
            if sender.state == UIGestureRecognizer.State.began {
                let tapLocation = sender.location(in: collectView)
                if let indexPath = collectView.indexPathForItem(at: tapLocation) {
                    if dataToPresent[indexPath.row].itemType == ItemType.directory.rawValue &&
                        !dataToPresent[userTap].children.isEmpty {
                        presentAlert(title: "You can't delete not empty directory", alertMessage: "", withTextField: false)
                    } else {
                        self.presentAlertAskUserForDelete(itemToDelete: "\(dataToPresent[indexPath.row].itemName)", indexPath: indexPath)
                    }
                }
            }
        } else {
            presentAlert(title: "Error", alertMessage: "Please, sign-in Google account for add new files.", withTextField: false)
        }
    }
}

// MARK: - Document Picker Delegate

extension MainViewController: UIDocumentPickerDelegate {
    
    private func presentFilePicker() {
        let types = [UTType.image, UTType.text, UTType.pdf, UTType.image, UTType.jpeg,    UTType.tiff, UTType.gif, UTType.png, UTType.rawImage, UTType.svg, UTType.livePhoto, UTType.movie, UTType.video, UTType.audio, UTType.quickTimeMovie, UTType.mpeg, UTType.mp3, UTType.zip, UTType.spreadsheet, UTType(filenameExtension: "pages")!, UTType(filenameExtension: "docx")!]
        let documentPickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
        documentPickerController.allowsMultipleSelection = false
        documentPickerController.delegate = self
        self.present(documentPickerController, animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let generatorItemUUID = SecCreateSharedWebCredentialPassword() as String?
        guard let randomItemUUID = generatorItemUUID else { return }
        let itemInRange = self.totalCountNodes + 1
        userDataManager.updateDataRequest(node: Node(itemUUID: randomItemUUID, parentItemUUID: self.parentItem(), itemType: "\(ItemType.file.rawValue)", itemName: urls[0].lastPathComponent, range: itemInRange), sheetID: spreadsheetId)
    }
}

// MARK: - UserDataManagerDelegate

extension MainViewController: UserDataManagerDelegate {
    
    func didUpdateData(_ dataManager: UserDataManager, data: Node) {
        isUpdated = false
        DispatchQueue.main.async {
            self.dataToPresent.append(data)
            self.totalCountNodes += 1
            if self.isRoot {
                self.userNode.append(data)
                self.isUpdated = true
            } else {
                while !self.isUpdated {
                    self.updateUserNodeForAdd(data: data, parent: self.userNode)
                }
            }
            self.isEmptyLabel.isHidden = true
            self.collectView.reloadData()
            self.isEmptyLabel.isHidden = self.dataToPresent.isEmpty ? false : true
        }
    }
    
    private func updateUserNodeForAdd(data: Node, parent: [Node]) {
        for item in parent {
            if item.itemUUID == self.parentItem() && !isUpdated {
                item.children.append(data)
                isUpdated = true
            }
            updateUserNodeForAdd(data: data, parent: item.children)
        }
    }
    
    func didGetData(_ dataManager: UserDataManager, data: [Node], range: Int) {
        DispatchQueue.main.async {
            self.userNode = data
            self.totalCountNodes = range
            self.dataToPresent = data
            self.collectView.reloadData()
            self.isEmptyLabel.isHidden = self.dataToPresent.isEmpty ? false : true
        }
    }
    
    private func parentItem() -> String {
        return dataToPresent.isEmpty ? parentItemIfDirectIsEmpty : dataToPresent[0].parentItemUUID
    }
    
    func didDeleteData(_ dataManager: UserDataManager, range: Int) {
        isUpdated = false
        
        self.dataToPresent.removeAll(where: { $0.range == range })
        self.totalCountNodes -= 1
        
        while !self.isUpdated {
            self.deleteNodeFromUserNode(range: range, parent: &self.userNode)
        }
        
        self.iterateCounter = (self.totalCountNodes + 1) - range
        self.updateUserNodeRange(range: range, parent: self.userNode)
        self.tempCounter.removeAll()
        DispatchQueue.main.async {
            self.collectView.reloadData()
            self.isEmptyLabel.isHidden = self.dataToPresent.isEmpty ? false : true
        }
    }
    
    private func deleteNodeFromUserNode(range: Int, parent: inout [Node]) {
        for item in parent {
            if item.range == range {
                parent.removeAll(where: { $0.range == range })
                isUpdated = true
            }
            deleteNodeFromUserNode(range: range, parent: &item.children)
        }
    }
    
    private func updateUserNodeRange(range: Int, parent: [Node]) {
        if iterateCounter != 0 {
            for item in parent {
                if item.range > range && iterateCounter != 0 && !tempCounter.contains(item.itemUUID) {
                    item.range -= 1
                    tempCounter.append(item.itemUUID)
                    iterateCounter -= 1
                }
                updateUserNodeRange(range: range, parent: item.children)
            }
        }
    }
    
    func didFailWithError(error: Error) {
        self.presentAlert(title: "Error", alertMessage: error.localizedDescription, withTextField: false)
    }
}

// MARK: - Present Alerts

extension MainViewController {
    
    private func presentAlert(title: String, alertMessage: String, withTextField: Bool) {
        let alertController = UIAlertController(title: title, message: alertMessage, preferredStyle: .alert)
        
        if withTextField {
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = " folder's name" })
            let OKAction = UIAlertAction(title: "Submit", style: .default, handler: { (action) -> Void in
                let generatorItemUUID = SecCreateSharedWebCredentialPassword() as String?
                guard let textFields = alertController.textFields else { return }
                guard let safeText = textFields[0].text else { return }
                guard let randomItemUUID = generatorItemUUID else { return }
                let itemInRange = self.totalCountNodes + 1
                self.userDataManager.updateDataRequest(node: Node(itemUUID: randomItemUUID, parentItemUUID: self.parentItem(), itemType: ItemType.directory.rawValue, itemName: safeText, range: itemInRange), sheetID: self.spreadsheetId)
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alertController.addAction(OKAction)
            alertController.addAction(cancelAction)
            
        } else {
            let OKAction = UIAlertAction(title: "OK", style: .default)
            alertController.addAction(OKAction)
        }
        self.present(alertController, animated: true, completion:nil)
    }
    
    private func presentAlertAskUserForDelete(itemToDelete: String, indexPath: IndexPath) {
        let alertController = UIAlertController(title: title, message: "Are you sure you want to delete \(itemToDelete)", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Yes", style: .default, handler: { (action) -> Void in
            self.userDataManager.deleteDataRequest(range: self.dataToPresent[indexPath.row].range, sheetID: self.spreadsheetId)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(OKAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion:nil)
    }
}
